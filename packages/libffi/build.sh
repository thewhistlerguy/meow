#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --with-gcc-arch=native

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
