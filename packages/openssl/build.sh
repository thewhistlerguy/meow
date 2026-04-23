#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

./config --prefix=/usr             --openssldir=/etc/ssl              --libdir=lib                       shared                             zlib-dynamic
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
rm -f "$MEOW_STAGE/usr/lib/libssl.a" "$MEOW_STAGE/usr/lib/libcrypto.a"
