# syntax=docker/dockerfile:1

ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-bookworm

ARG USER=www-data
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip libjpeg-dev libwebp-dev libzip-dev libicu-dev libonig-dev libxml2-dev libmagickwand-dev \
    && install-php-extensions bcmath exif gd intl mysqli pdo_mysql zip imagick opcache redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY composer.json composer.lock* ./
RUN if [ -f composer.lock ]; then \
        composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader --classmap-authoritative; \
    else \
        composer update --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader --classmap-authoritative; \
    fi

COPY . .

RUN mkdir -p /opt/project-mu-plugins /app/web/app/uploads \
    && if [ -d /app/web/app/mu-plugins ]; then cp -a /app/web/app/mu-plugins/. /opt/project-mu-plugins/; fi \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && chown -R ${USER}:${USER} /app \
    && { echo "opcache.enable=1"; echo "opcache.memory_consumption=192"; echo "opcache.interned_strings_buffer=16"; echo "opcache.max_accelerated_files=20000"; echo "opcache.validate_timestamps=0"; echo "opcache.save_comments=1"; } > /usr/local/etc/php/conf.d/10-opcache-recommended.ini

COPY docker/common/sync-mu-plugins.sh /usr/local/bin/sync-mu-plugins
COPY docker/common/wp-entrypoint.sh /usr/local/bin/wp-entrypoint
COPY docker/php-fpm/entrypoint.sh /usr/local/bin/php-fpm-entrypoint
COPY docker/php-fpm/php.ini /usr/local/etc/php/conf.d/99-app.ini
RUN chmod +x /usr/local/bin/sync-mu-plugins /usr/local/bin/wp-entrypoint /usr/local/bin/php-fpm-entrypoint

USER ${USER}

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD php-fpm -t || exit 1

ENTRYPOINT ["/usr/local/bin/php-fpm-entrypoint"]
