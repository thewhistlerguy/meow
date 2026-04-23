#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
