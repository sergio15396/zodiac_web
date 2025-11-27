# --- STAGE 1: Node Builder (Vite / assets) ---
FROM node:20-alpine AS node_builder
WORKDIR /app

# Copy package files and install Node dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the code and build assets
COPY . .
RUN npm run build

# --- STAGE 2: PHP / Composer ---
FROM php:8.3-cli AS composer_builder
WORKDIR /app

# Install system dependencies for PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl unzip libzip-dev libicu-dev zlib1g-dev libpng-dev libonig-dev libxml2-dev sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel
RUN docker-php-ext-install -j"$(nproc)" pdo_mysql pdo_sqlite mbstring bcmath intl zip exif pcntl \
    && docker-php-ext-enable opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Laravel app + built assets from Node stage
COPY --from=node_builder /app /app

# Install Composer dependencies
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# --- STAGE 3: Final PHP-FPM image ---
FROM php:8.3-fpm-alpine

# Install runtime dependencies
RUN apk add --no-cache icu sqlite-libs libzip unzip git curl bash libpng libxml2

# Copy PHP extensions from builder
COPY --from=composer_builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=composer_builder /usr/local/etc/php /usr/local/etc/php
COPY --from=composer_builder /app /var/www/html

# Set working directory
WORKDIR /var/www/html

# Generate Laravel key and cache configs
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

USER www-data

EXPOSE 9000
CMD ["php-fpm"]
