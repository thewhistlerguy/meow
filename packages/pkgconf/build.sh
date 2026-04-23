#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/pkgconf-2.2.0

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
ln -sf pkgconf "$MEOW_STAGE/usr/bin/pkg-config"

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/pkgconf" 2>/dev/null || true
