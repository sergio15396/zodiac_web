# Stage 1 — Composer dependencies
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist

# Stage 2 — Build Laravel App
FROM php:8.1-fpm
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && docker-php-ext-enable pdo_mysql

COPY --from=vendor /app/vendor ./vendor
COPY . .

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

EXPOSE 9000
CMD ["php-fpm"]
