# syntax=docker/dockerfile:1

ARG FRANKENPHP_VERSION=1.12.7
ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-bookworm

ARG USER=www-data
ARG WP_CLI_VERSION=2.12.0
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip libjpeg-dev libwebp-dev libzip-dev libicu-dev libonig-dev libxml2-dev libmagickwand-dev libcap2-bin \
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

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && { echo "upload_max_filesize=512M"; echo "post_max_size=512M"; echo "memory_limit=256M"; echo "max_execution_time=300"; echo "display_errors=Off"; echo "log_errors=On"; echo "error_log=/dev/stderr"; } > "$PHP_INI_DIR/conf.d/99-wordpress.ini" \
    && { echo "opcache.enable=1"; echo "opcache.memory_consumption=192"; echo "opcache.interned_strings_buffer=16"; echo "opcache.max_accelerated_files=20000"; echo "opcache.validate_timestamps=0"; echo "opcache.save_comments=1"; } > "$PHP_INI_DIR/conf.d/10-opcache-recommended.ini" \
    && mkdir -p /opt/project-mu-plugins /app/web/app/uploads \
    && if [ -d /app/web/app/mu-plugins ]; then cp -a /app/web/app/mu-plugins/. /opt/project-mu-plugins/; fi \
    && curl -fsSL https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && chown -R ${USER}:${USER} /app /data/caddy /config/caddy \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

COPY docker/common/sync-mu-plugins.sh /usr/local/bin/sync-mu-plugins
COPY docker/common/wp-entrypoint.sh /usr/local/bin/wp-entrypoint
COPY docker/frankenphp/Caddyfile /etc/frankenphp/Caddyfile
COPY docker/frankenphp/Caddyfile.worker /etc/frankenphp/Caddyfile.worker
COPY docker/frankenphp/entrypoint.sh /usr/local/bin/frankenphp-entrypoint
RUN chmod +x /usr/local/bin/sync-mu-plugins /usr/local/bin/wp-entrypoint /usr/local/bin/frankenphp-entrypoint

USER ${USER}

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD curl -fsS http://127.0.0.1/healthz >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/frankenphp-entrypoint"]
