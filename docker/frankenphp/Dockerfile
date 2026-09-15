FROM dunglas/frankenphp:1-php8.3-bookworm

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip curl libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" mysqli pdo_mysql intl zip gd opcache \
    && install-php-extensions redis \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json ./
RUN composer update --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader

COPY . .

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY docker/frankenphp/Caddyfile /etc/frankenphp/Caddyfile

RUN mkdir -p /app/web/app/uploads \
    && chown -R www-data:www-data /app/web/app
