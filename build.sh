#!/bin/bash
# build.sh — called by meow build
# Env vars provided by meow:
#   MEOW_WORK   = extracted source directory
#   MEOW_STAGE  = staging root (install here instead of /)
#   MEOW_NAME, MEOW_VER, MEOW_REL

set -euo pipefail

./configure \
    --prefix=/usr \
    --without-bash-malloc \
    --with-installed-readline \
    --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install

# Symlink sh → bash
ln -sf bash "$MEOW_STAGE/usr/bin/sh"

# Strip binaries to save space
strip --strip-unneeded "$MEOW_STAGE/usr/bin/bash"
