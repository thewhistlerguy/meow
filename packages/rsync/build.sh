#!/bin/bash
# build.sh — rsync
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --disable-lz4     --disable-zstd     --without-included-zlib
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
