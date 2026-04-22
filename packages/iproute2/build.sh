#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make make SBINDIR=/usr/sbin -j$(nproc)

make SBINDIR=/usr/sbin DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/sbin/ip" 2>/dev/null || true
