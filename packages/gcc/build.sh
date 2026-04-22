#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-bootstrap \
    --with-system-zlib

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
ln -sf gcc "$MEOW_STAGE/usr/bin/cc"

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/gcc" 2>/dev/null || true
strip --strip-unneeded "$MEOW_STAGE/usr/bin/g++" 2>/dev/null || true
