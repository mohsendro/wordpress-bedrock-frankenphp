#!/usr/bin/env sh
set -eu

docker compose --profile tools run --rm wp-cli "$@"
