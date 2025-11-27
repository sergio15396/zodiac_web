# ------------------------------
# Stage 1: Node (build assets)
# ------------------------------
FROM node:20-bullseye AS node_builder
WORKDIR /app

# Copy Node package files
COPY package*.json ./
RUN npm ci

# Copy application code
COPY . .

# Build assets
RUN npm run build

# ------------------------------
# Stage 2: PHP dependencies (Composer)
# ------------------------------
FROM composer:2 AS composer_builder
WORKDIR /app

# Copy app + built assets from node stage
COPY --from=node_builder /app /app

# Install PHP dependencies
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# ------------------------------
# Stage 3: Final production image
# ------------------------------
FROM php:8.2-fpm-bullseye

# Install system dependencies + PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    bash \
    sqlite3 \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql pdo_sqlite mbstring bcmath intl zip exif pcntl \
    && docker-php-ext-enable opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy Laravel app + assets from composer stage
COPY --from=composer_builder /app /var/www/html

# Prepare Laravel environment & cache
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force

# Set permissions for Laravel storage and bootstrap/cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Run as non-root
USER www-data

# Expose PHP-FPM port
EXPOSE 9000
