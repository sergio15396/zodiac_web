# ------------------------------
# Stage 1: Build Stage (PHP + Node)
# ------------------------------
FROM php:8.2-fpm AS builder

WORKDIR /var/www/html

# Install system dependencies for PHP + Node.js
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    git \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && docker-php-ext-enable pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy only composer files first (cache layer)
COPY composer.json composer.lock ./

# Install PHP dependencies without running artisan scripts (artisan not yet available)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy Node.js files for front-end caching
COPY package.json package-lock.json ./

# Install Node.js dependencies
RUN npm install

# Copy full application source code
COPY . .

# Build front-end assets
RUN npm run build

# Run composer scripts now that full source is available
RUN composer run-script post-install-cmd || echo "Skipping artisan scripts in build stage"

# ------------------------------
# Stage 2: Production Stage (Lightweight)
# ------------------------------
FROM php:8.2-fpm

WORKDIR /var/www/html

# Install only PHP runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl \
    && docker-php-ext-enable pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Copy PHP vendor files and compiled front-end assets from builder
COPY --from=builder /var/www/html/vendor ./vendor
COPY --from=builder /var/www/html/public ./public

# Copy essential Laravel directories
COPY --from=builder /var/www/html/app ./app
COPY --from=builder /var/www/html/config ./config
COPY --from=builder /var/www/html/database ./database
COPY --from=builder /var/www/html/resources ./resources
COPY --from=builder /var/www/html/routes ./routes

# Copy composer binary
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

# Cache config, routes, and views for faster performance
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
