#!/bin/bash
# build.sh — gdb
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
mkdir build && cd build
../configure     --prefix=/usr     --with-system-readline     --with-python=/usr/bin/python3     --with-debuginfod     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
