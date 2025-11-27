# --- STAGE 1: Node (Build assets) ---
FROM node:20-alpine AS node_builder
WORKDIR /app

# Copy Node files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy rest of the app and build assets
COPY . .
RUN npm run build

# --- STAGE 2: PHP Dependencies (Composer) ---
FROM php:8.4-fpm AS composer_builder
WORKDIR /app

# Install system dependencies for PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev libonig-dev libzip-dev unzip git curl bash sqlite3 libicu-dev zlib1g-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring bcmath intl zip exif pcntl \
    && docker-php-ext-enable opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy app code + assets from Node stage
COPY --from=node_builder /app /app

# Force Composer to respect PHP 8.4 (avoid version conflicts)
RUN composer config platform.php 8.4.28

# Install PHP dependencies
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --- STAGE 3: Final Image ---
FROM php:8.4-fpm

WORKDIR /var/www/html

# Install runtime PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev libonig-dev libzip-dev sqlite3 libicu-dev zlib1g-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring bcmath intl zip exif pcntl \
    && docker-php-ext-enable opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy built app + dependencies
COPY --from=composer_builder /app /var/www/html

# Prepare environment
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && php artisan migrate --force

# Fix permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Run as non-root
USER www-data

# Expose PHP-FPM port
EXPOSE 9000
