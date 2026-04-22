#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --disable-static \
    --with-openssl \
    --enable-versioned-symbols \
    --enable-threaded-resolver \
    --with-ca-path=/etc/ssl/certs

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/curl" 2>/dev/null || true
