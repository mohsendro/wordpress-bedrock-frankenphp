#!/usr/bin/env sh
set -eu
/usr/local/bin/sync-mu-plugins
exec "$@"
