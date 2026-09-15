#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

FRANKENPHP_ENABLED="${FRANKENPHP_ENABLED:-true}"

if [ "$FRANKENPHP_ENABLED" = "true" ]; then
  set -- -f compose.yaml -f compose.frankenphp.yaml "$@"
else
  set -- -f compose.yaml -f compose.php-fpm.yaml "$@"
fi

exec docker compose "$@"
