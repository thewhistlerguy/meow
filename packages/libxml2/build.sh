#!/bin/bash
# build.sh — libxml2
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc     --disable-static     --with-history     --with-icu     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}     PYTHON=/usr/bin/python3
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
