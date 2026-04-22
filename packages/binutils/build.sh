#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --enable-gold \
    --enable-ld=default \
    --enable-plugins \
    --enable-shared \
    --disable-werror \
    --enable-64-bit-bfd

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
rm -fv "$MEOW_STAGE/usr/lib/lib"{bfd,ctf,ctf-nobfd,opcodes,sframe}.a
