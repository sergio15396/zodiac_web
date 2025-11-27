# ============================
# Stage 1: Node (Assets)
# ============================
FROM node:20-alpine AS node_builder
WORKDIR /app

# Copy Node manifest files
COPY package*.json ./

# Install Node dependencies
RUN npm ci

# Copy the rest of the source code
COPY . .

# Build frontend assets
RUN npm run build

# ============================
# Stage 2: Composer (PHP dependencies)
# ============================
FROM composer:2.5 AS composer_builder
WORKDIR /app

# Copy all source + built assets from Node stage
COPY --from=node_builder /app /app

# Install PHP dependencies (no dev, optimized)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# ============================
# Stage 3: Final PHP Image
# ============================
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
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
        libxml2-dev \
        libonig-dev; \
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

# Set working directory
WORKDIR /var/www/html

# Copy app + dependencies from composer stage
COPY --from=composer_builder /app /var/www/html

# Prepare Laravel (env, key, cache)
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Fix permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Use non-root user for security
USER www-data

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
# ============================