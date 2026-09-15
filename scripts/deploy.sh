#!/usr/bin/env sh
set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

FRANKENPHP_ENABLED="${FRANKENPHP_ENABLED:-true}"
export IMAGE_TAG="${IMAGE_TAG:?IMAGE_TAG must be set}"

if [ "$FRANKENPHP_ENABLED" = "true" ]; then
  RUNTIME_FILE=compose.production.frankenphp.yaml
else
  RUNTIME_FILE=compose.production.php-fpm.yaml
fi

COMPOSE="docker compose -f compose.yaml -f compose.production.yaml -f $RUNTIME_FILE"
PREVIOUS_TAG=""
if [ -f .deployed-tag ]; then
  PREVIOUS_TAG=$(cat .deployed-tag)
fi

if [ -n "$PREVIOUS_TAG" ] && [ "$PREVIOUS_TAG" = "$IMAGE_TAG" ]; then
  printf '%s\n' "Version $IMAGE_TAG is already deployed."
  exit 0
fi

./scripts/backup-db.sh || true

rollback() {
  if [ -n "$PREVIOUS_TAG" ]; then
    printf '%s\n' "Deployment failed. Rolling back to $PREVIOUS_TAG..."
    export IMAGE_TAG="$PREVIOUS_TAG"
    $COMPOSE pull || true
    $COMPOSE up -d --remove-orphans --wait || true
  fi
}

trap 'rollback' INT TERM ERR

$COMPOSE pull
$COMPOSE up -d --remove-orphans --wait

./scripts/healthcheck.sh "${HEALTHCHECK_URL:-http://localhost}"

$COMPOSE --profile tools run --rm wp-cli core update-db || true

printf '%s\n' "$IMAGE_TAG" > .deployed-tag

docker image prune -f
trap - INT TERM ERR

printf '%s\n' "Deployment completed successfully: $IMAGE_TAG"
