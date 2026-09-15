#!/usr/bin/env sh
set -eu
/usr/local/bin/sync-mu-plugins
MODE="${FRANKENPHP_MODE:-classic}"
case "$MODE" in
  classic) cp /etc/frankenphp/Caddyfile /etc/frankenphp/Caddyfile.active ;;
  worker) echo "WARNING: FrankenPHP worker mode is opt-in. Verify plugin/theme compatibility before production use."; cp /etc/frankenphp/Caddyfile.worker /etc/frankenphp/Caddyfile.active ;;
  *) echo "Invalid FRANKENPHP_MODE: $MODE. Use classic or worker." >&2; exit 1 ;;
esac
exec frankenphp run --config /etc/frankenphp/Caddyfile.active --adapter caddyfile
