#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/procps-ng-4.0.4 \
    --disable-static \
    --disable-kill

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
