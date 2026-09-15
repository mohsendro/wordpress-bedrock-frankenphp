#!/usr/bin/env sh
set -eu

docker compose -f compose.yaml -f compose.production.yaml pull
docker compose -f compose.yaml -f compose.production.yaml up -d --remove-orphans
docker compose -f compose.yaml -f compose.production.yaml ps
