ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:1-php${PHP_VERSION}-bookworm

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip curl libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" mysqli pdo_mysql intl zip gd opcache \
    && install-php-extensions redis \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock* ./
RUN if [ -f composer.lock ]; then composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader; else composer update --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader; fi

COPY . .

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /app/web/app/uploads \
    && chown -R www-data:www-data /app/web/app

COPY docker/frankenphp/Caddyfile /etc/frankenphp/Caddyfile
COPY docker/frankenphp/Caddyfile.worker /etc/frankenphp/Caddyfile.worker
COPY docker/frankenphp/entrypoint.sh /usr/local/bin/frankenphp-entrypoint

RUN chmod +x /usr/local/bin/frankenphp-entrypoint

ENTRYPOINT ["/usr/local/bin/frankenphp-entrypoint"]
