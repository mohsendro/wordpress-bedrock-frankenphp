#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

FRANKENPHP_ENABLED="${FRANKENPHP_ENABLED:-true}"

if [ "$FRANKENPHP_ENABLED" = "true" ]; then
  RUNTIME_FILE=compose.production.frankenphp.yaml
else
  RUNTIME_FILE=compose.production.php-fpm.yaml
fi

export IMAGE_TAG="${IMAGE_TAG:?IMAGE_TAG must be set}"

COMPOSE="docker compose -f compose.yaml -f compose.production.yaml -f $RUNTIME_FILE"

$COMPOSE pull
$COMPOSE up -d --remove-orphans --wait
./scripts/healthcheck.sh "${HEALTHCHECK_URL:-http://localhost}"
docker image prune -f

printf '%s\n' "Deployment completed successfully."
