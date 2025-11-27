# --- STAGE 1: Node (Assets) ---
FROM node:20-alpine AS node_builder
WORKDIR /app

# Copy Node files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy rest of the application and build assets
COPY . .
RUN npm run build

# --- STAGE 2: PHP Dependencies (Composer) ---
FROM composer:2.6-php8.4 AS composer_builder
WORKDIR /app

# Copy app + built assets from node stage
COPY --from=node_builder /app /app

# Install PHP dependencies (no dev for production)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --- STAGE 3: Final PHP Image ---
FROM php:8.4-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev libonig-dev libzip-dev sqlite3 libicu-dev zlib1g-dev libxml2-dev git unzip curl bash \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql pdo_sqlite mbstring bcmath intl zip exif pcntl \
    && docker-php-ext-enable opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copy app and dependencies from composer stage
COPY --from=composer_builder /app /var/www/html

# Prepare Laravel environment
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Use non-root user
USER www-data

# Expose PHP-FPM port
EXPOSE 9000
