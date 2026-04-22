#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --enable-no-install-program=kill,uptime

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
