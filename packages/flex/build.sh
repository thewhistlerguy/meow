#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/flex-2.6.4 \
    --disable-static

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/flex" 2>/dev/null || true
