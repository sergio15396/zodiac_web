# ------------------------------
# Stage 1: Node + Build frontend
# ------------------------------
FROM node:20-alpine AS node_builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY vite.config.js ./

# Install dependencies
RUN npm install

# Copy frontend source code
COPY resources resources
COPY public public

# Build frontend
RUN npm run build

# ------------------------------
# Stage 2: PHP + Laravel
# ------------------------------
FROM php:8.3-fpm

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
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

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy Laravel backend + frontend build
COPY --from=node_builder /app /var/www/html

# Copy existing Laravel files
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Environment & Laravel key
RUN cp .env.example .env \
    && php artisan key:generate

# Expose port
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
# ------------------------------