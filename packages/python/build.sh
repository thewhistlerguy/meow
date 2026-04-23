#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --enable-shared \
    --with-system-expat \
    --enable-optimizations

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
ln -sf python3 "$MEOW_STAGE/usr/bin/python"
ln -sf pip3 "$MEOW_STAGE/usr/bin/pip" 2>/dev/null || true
