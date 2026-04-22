#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --docdir=/usr/share/doc/expat-2.6.2

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
