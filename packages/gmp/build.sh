#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --enable-cxx \
    --disable-static \
    --docdir=/usr/share/doc/gmp-6.3.0

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
