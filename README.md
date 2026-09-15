# WordPress Bedrock + FrankenPHP Starter

Production-oriented WordPress starter built around Bedrock, Composer/WP Packages, Docker, FrankenPHP, MySQL, Redis and WP-CLI.

## Stack

- Bedrock
- WordPress Core via Composer / WP Packages
- FrankenPHP
- MySQL 8.4
- Redis
- WP-CLI
- Mailpit for local email testing
- Docker Compose
- GitHub Actions / GHCR

## Quick start

1. Copy environment file:
   cp .env.example .env

2. Start the stack:
   docker compose up -d --build

3. Install WordPress:
   docker compose run --rm wp-cli core install \
     --url=http://localhost \
     --title="WordPress" \
     --admin_user=admin \
     --admin_password=change-me \
     --admin_email=admin@example.test

4. Open:
   http://localhost

Mailpit:
   http://localhost:8025

## Production

Production secrets/configuration must live on the server, not in Git. Set IMAGE_TAG in the server environment and run:

docker compose -f compose.yaml -f compose.production.yaml pull
docker compose -f compose.yaml -f compose.production.yaml up -d

See .env.example and the deployment workflow for the expected production variables.
