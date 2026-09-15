ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-bookworm
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip curl libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" mysqli pdo_mysql intl zip gd opcache \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock* ./
RUN if [ -f composer.lock ]; then composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader; else composer update --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader; fi
COPY . .
RUN mkdir -p /opt/project-mu-plugins \
    && if [ -d /app/web/app/mu-plugins ]; then cp -a /app/web/app/mu-plugins/. /opt/project-mu-plugins/; fi \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /app/web/app/uploads \
    && chown -R www-data:www-data /app/web/app
COPY docker/common/sync-mu-plugins.sh /usr/local/bin/sync-mu-plugins
COPY docker/common/wp-entrypoint.sh /usr/local/bin/wp-entrypoint
COPY docker/php-fpm/entrypoint.sh /usr/local/bin/php-fpm-entrypoint
RUN chmod +x /usr/local/bin/sync-mu-plugins /usr/local/bin/wp-entrypoint /usr/local/bin/php-fpm-entrypoint
COPY docker/php-fpm/php.ini /usr/local/etc/php/conf.d/99-app.ini
ENTRYPOINT ["/usr/local/bin/php-fpm-entrypoint"]
