# Stage 1 — Composer dependencies
ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-cli AS vendor
WORKDIR /app

COPY composer.json composer.lock ./

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    DEBIAN_FRONTEND=noninteractive

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends git unzip curl gnupg ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --no-interaction --prefer-dist || composer install --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

# Stage 2 — Build Laravel App
FROM php:8.2-fpm
WORKDIR /var/www/html

# System dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && docker-php-ext-enable pdo_mysql

# Copy vendor from previous stage
COPY --from=vendor /app/vendor ./vendor

# Copy app source
COPY . .

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache \
    && composer dump-autoload --optimize

EXPOSE 9000
CMD ["php-fpm"]
