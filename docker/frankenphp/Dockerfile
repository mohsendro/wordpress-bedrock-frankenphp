FROM dunglas/frankenphp:1-php8.3-bookworm

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" mysqli pdo_mysql intl zip gd opcache \
    && install-php-extensions redis \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock* ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

COPY . .

COPY docker/frankenphp/Caddyfile /etc/frankenphp/Caddyfile

RUN mkdir -p /app/web/app/uploads \
    && chown -R www-data:www-data /app/web/app
