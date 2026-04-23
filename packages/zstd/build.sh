#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make make prefix=/usr DESTDIR="$MEOW_STAGE"

make prefix=/usr DESTDIR="$MEOW_STAGE" install
rm -f "$MEOW_STAGE/usr/lib/libzstd.a"

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/zstd" 2>/dev/null || true
