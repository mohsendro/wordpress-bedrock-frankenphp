#!/usr/bin/env sh
set -eu

URL="${1:-http://localhost}"

curl --fail --silent --show-error --max-time 10 "$URL/" >/dev/null
printf '%s\n' "Health check passed: $URL"
