#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

make -f Makefile-libbz2_so
make -j$(nproc)
make PREFIX="$MEOW_STAGE/usr" install
cp -av libbz2.so* "$MEOW_STAGE/usr/lib/"
ln -sv libbz2.so.1.0.8 "$MEOW_STAGE/usr/lib/libbz2.so"
ln -sv bzip2 "$MEOW_STAGE/usr/bin/bunzip2"
ln -sv bzip2 "$MEOW_STAGE/usr/bin/bzcat"

# Strip binaries
strip --strip-unneeded "$MEOW_STAGE/usr/bin/bzip2" 2>/dev/null || true
