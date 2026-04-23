#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-ssl=openssl

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/wget" 2>/dev/null || true
