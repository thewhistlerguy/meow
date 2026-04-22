#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/mpc-1.3.1

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
