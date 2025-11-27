# ------------------------------
# Stage 1: Build PHP dependencies
# ------------------------------
FROM php:8.2-fpm AS builder

WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libonig-dev \
        libzip-dev \
        zip \
        unzip \
        curl \
        git \
        && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
        && docker-php-ext-enable pdo_mysql \
        && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy only composer files first to leverage Docker cache
COPY composer.json composer.lock ./

# Copy artisan and essential files needed for post-autoload scripts
COPY artisan ./
COPY app ./app
COPY bootstrap ./bootstrap
COPY config ./config
COPY database ./database
COPY routes ./routes
COPY resources ./resources

# Install PHP dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# ------------------------------
# Stage 2: Final runtime image
# ------------------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

# Install system dependencies (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev \
        libzip-dev \
        zip \
        unzip \
        && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
        && docker-php-ext-enable pdo_mysql \
        && rm -rf /var/lib/apt/lists/*

# Copy Composer from builder
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

# Copy Laravel app
COPY --from=builder /var/www/html /var/www/html

# Cache config, routes, and views for faster performance
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port 9000 and start PHP-FPM
EXPOSE 9000
CMD ["php-fpm"]
