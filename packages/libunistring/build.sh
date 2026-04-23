#!/bin/bash
# build.sh — libunistring
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --disable-static     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
