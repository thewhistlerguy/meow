#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-vlock

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
