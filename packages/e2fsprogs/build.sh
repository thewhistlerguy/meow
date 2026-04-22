#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-uuidd \
    --disable-fsck

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
make DESTDIR="$MEOW_STAGE" install-libs
chmod -v u+w "$MEOW_STAGE/usr/lib/"{libcom_err,libe2p,libext2fs,libss}.a || true
