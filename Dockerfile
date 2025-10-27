# Simple Dockerfile for deploying this Laravel app to Render's free Docker web service
# Notes:
# - This uses the PHP CLI image and runs Laravel's built-in server (php artisan serve).
# - Render sets the PORT environment variable; the container will use $PORT if provided.
# - For production-grade deployments consider using php-fpm + nginx. This is a lightweight, "works on Render free" image.

FROM php:8.2-cli

# Install system dependencies and PHP extensions commonly used by Laravel
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       unzip \
       libzip-dev \
       libpng-dev \
       libonig-dev \
       libxml2-dev \
       zip \
       curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath zip \
    && rm -rf /var/lib/apt/lists/*

# Install composer from the official composer image for reliability
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy composer files first to leverage Docker layer cache
COPY composer.json composer.lock* ./

# Install PHP dependencies (no dev for smaller image). If composer.lock missing, this step will still run.
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --optimize-autoloader || true

# Copy the application
COPY . .

# Ensure storage and cache directories are writable
RUN mkdir -p storage/framework storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache || true

# Default environment settings
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV PORT=8080

# Expose the port (Render will set PORT env var and map it)
EXPOSE ${PORT}

# Start the lightweight built-in PHP server that listens on the PORT provided by Render
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT}"]
