#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --sysconfdir=/etc

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/less" 2>/dev/null || true
