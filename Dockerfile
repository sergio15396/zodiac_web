# --- STAGE 1: Node (Assets) ---
FROM node:20-alpine AS node_builder
WORKDIR /app

# Copy package.json & package-lock.json
COPY package*.json ./

# Install Node dependencies
RUN npm ci

# Copy rest of the app
COPY . .

# Build assets
RUN npm run build

# --- STAGE 2: PHP Dependencies (Composer) ---
FROM composer:2 AS composer_builder
WORKDIR /app

# Copy app + built assets from Node stage
COPY --from=node_builder /app /app

# Install PHP dependencies (production)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --- STAGE 3: Final Image ---
FROM php:8.4-fpm

# Install system dependencies & PHP extensions
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libpng-dev \
        libonig-dev \
        libzip-dev \
        unzip \
        git \
        curl \
        bash \
        sqlite3 \
        libicu-dev \
        zlib1g-dev \
        libxml2-dev; \
    docker-php-ext-configure intl; \
    docker-php-ext-install -j"$(nproc)" \
        pdo_mysql \
        pdo_sqlite \
        mbstring \
        bcmath \
        intl \
        zip \
        exif \
        pcntl; \
    docker-php-ext-enable opcache; \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copy app + dependencies from composer stage
COPY --from=composer_builder /app /var/www/html

# Prepare Laravel
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && touch database/database.sqlite \
    && php artisan migrate --force

# Permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Run as www-data
USER www-data

# Expose PHP-FPM
EXPOSE 9000
