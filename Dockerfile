# --- STAGE 1: Node.js (Build Frontend Assets) ---
FROM node:20-alpine AS node_builder
WORKDIR /app

# Copy Node package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the frontend code
COPY . .

# Build production assets
RUN npm run build

# --- STAGE 2: Composer (PHP Dependencies) ---
FROM composer:2 AS composer_builder
WORKDIR /app

# Copy PHP app code and Node-built assets
COPY --from=node_builder /app /app

# Install PHP dependencies (without dev packages)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --- STAGE 3: Final PHP Image ---
FROM php:8.4-fpm

WORKDIR /var/www/html

# Install system dependencies for PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    bash \
    sqlite3 \
    libsqlite3-dev \
    libicu-dev \
    zlib1g-dev \
    libxml2-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        pdo_sqlite \
        mbstring \
        bcmath \
        intl \
        zip \
        exif \
        pcntl \
    && docker-php-ext-enable opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Laravel app with dependencies and built assets
COPY --from=composer_builder /app /var/www/html

# Set up environment if .env is missing
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Switch to non-root user
USER www-data

# Expose PHP-FPM port
EXPOSE 9000
