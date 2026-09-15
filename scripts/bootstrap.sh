#!/usr/bin/env sh
set -eu

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example. Review passwords and runtime settings before continuing."
fi

if [ ! -f composer.lock ]; then
  echo "No composer.lock found. Resolving dependencies for the first time..."
  docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/app" -w /app composer:2 install --no-interaction --prefer-dist --no-progress
fi

./scripts/compose.sh up -d --build --wait

printf '%s\n' "Starter is running."
printf '%s\n' "Site: ${WP_HOME:-http://localhost}"
printf '%s\n' "Mailpit: http://localhost:8025"
