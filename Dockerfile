# --- STAGE 1: Node (Build Frontend Assets) ---
FROM node:20-alpine AS node_builder

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the frontend code
COPY . .

# Build assets for production
RUN npm run build

# --- STAGE 2: PHP Dependencies (Composer) ---
FROM composer:2 AS composer_builder

WORKDIR /app

# Copy all files from Node build stage (assets included)
COPY --from=node_builder /app /app

# Install PHP dependencies for production
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --- STAGE 3: Final PHP + Node Image ---
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions (SQLite + Laravel essentials)
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libpng-dev \
        libonig-dev \
        libzip-dev \
        libicu-dev \
        zlib1g-dev \
        libxml2-dev \
        sqlite3 \
        curl \
        bash \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_sqlite \
        mbstring \
        bcmath \
        intl \
        zip \
        exif \
        pcntl \
    && docker-php-ext-enable opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node for running dev scripts (Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Copy application code and built assets from Composer stage
COPY --from=composer_builder /app /var/www/html

# Ensure SQLite database exists
RUN if [ ! -f database/database.sqlite ]; then mkdir -p database && touch database/database.sqlite; fi

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Copy .env if not present and generate key
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate

# Expose PHP-FPM port
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
