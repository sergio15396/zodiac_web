# ------------------------------
# Stage 1: Build PHP dependencies
# ------------------------------
FROM php:8.2-fpm AS builder

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    curl \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-enable pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer files first for caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# ------------------------------
# Stage 2: Build Node.js/Vite assets
# ------------------------------
FROM node:20 AS node-builder

WORKDIR /var/www/html

# Copy app code and vendor
COPY --from=builder /var/www/html /var/www/html

# Install Node dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Build frontend assets
RUN npm run build

# ------------------------------
# Stage 3: Final PHP image
# ------------------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

# Install PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && docker-php-ext-enable pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Copy PHP dependencies and composer
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
COPY --from=builder /var/www/html/vendor ./vendor

# Copy built frontend assets
COPY --from=node-builder /var/www/html/public ./public

# Copy the rest of the application
COPY . .

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
