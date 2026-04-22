#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-xz \
    --with-zstd \
    --with-zlib \
    --with-openssl

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
for tool in insmod rmmod lsmod modprobe modinfo depmod; do
    ln -sf kmod "$MEOW_STAGE/usr/bin/$tool"
done

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/kmod" 2>/dev/null || true
