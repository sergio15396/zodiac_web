# ------------------------------
# Stage 0: Build PHP extensions & install Composer dependencies
# ------------------------------
FROM php:8.2-fpm AS builder

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libonig-dev \
        libzip-dev \
        zip \
        unzip \
        curl \
        git \
        libpq-dev \
        && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
        && docker-php-ext-enable pdo_mysql \
        && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Laravel composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy the rest of the application
COPY . .

# ------------------------------
# Stage 1: Final runtime image
# ------------------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

# Copy PHP extensions and composer from builder
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
COPY --from=builder /var/www/html/vendor ./vendor

# Copy Laravel app directories
COPY --from=builder /var/www/html/app ./app
COPY --from=builder /var/www/html/bootstrap ./bootstrap
COPY --from=builder /var/www/html/config ./config
COPY --from=builder /var/www/html/database ./database
COPY --from=builder /var/www/html/public ./public
COPY --from=builder /var/www/html/resources ./resources
COPY --from=builder /var/www/html/routes ./routes

# Copy root files like artisan
COPY --from=builder /var/www/html/artisan ./artisan
COPY --from=builder /var/www/html/composer.json ./composer.json
COPY --from=builder /var/www/html/composer.lock ./composer.lock
COPY --from=builder /var/www/html/.env.example ./.env

# Set permissions (optional, adjust to your user/group)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Cache config, routes, and views
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port 9000 and start php-fpm
EXPOSE 9000
CMD ["php-fpm"]
