#!/usr/bin/env sh
set -eu
SOURCE="/opt/project-mu-plugins"
TARGET="/app/web/app/mu-plugins"
mkdir -p "$TARGET"
rm -rf "$TARGET"
mkdir -p "$TARGET"
if [ -d "$SOURCE" ]; then cp -a "$SOURCE"/. "$TARGET"/; fi
chown -R www-data:www-data "$TARGET" 2>/dev/null || true
