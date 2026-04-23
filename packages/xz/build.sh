#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/xz-5.6.1

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/xz" 2>/dev/null || true
