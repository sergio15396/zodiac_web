# --------------------------
# Stage 1: Build Node assets
# --------------------------
FROM node:20 AS node_builder
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build assets
RUN npm run build

# --------------------------
# Stage 2: Install Composer dependencies
# --------------------------
FROM composer:2.6 AS composer_builder
WORKDIR /app

# Copy app code + built assets
COPY --from=node_builder /app /app

# Install PHP dependencies (without dev for production)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --------------------------
# Stage 3: Final PHP image
# --------------------------
FROM php:8.3-fpm

# Install system dependencies and PHP extensions
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
        default-mysql-client \
        libmysqlclient-dev \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy app + assets + vendor
COPY --from=composer_builder /app /var/www/html

# Copy .env if it doesn’t exist and generate key
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force

# Permissions for Laravel storage/cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Use non-root user
USER www-data

# Expose PHP-FPM port
EXPOSE 9000
