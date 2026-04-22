#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --sysconfdir=/etc \
    --docdir=/usr/share/doc/attr-2.5.2

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
