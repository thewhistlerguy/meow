#!/bin/bash
# build.sh — htop
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --disable-unicode
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
