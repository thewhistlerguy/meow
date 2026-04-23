#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --sysconfdir=/etc \
    --disable-static \
    --with-{b,s}crypt \
    --without-libbsd \
    --with-group-name-max-length=32

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
