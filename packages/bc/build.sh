#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

CC=gcc ./configure.sh --prefix=/usr -G -O3
make DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/bc" 2>/dev/null || true
