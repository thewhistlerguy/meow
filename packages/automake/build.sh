#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/automake-1.16.5

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
