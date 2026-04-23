#!/bin/bash
# build.sh — pciutils
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
make -j$(nproc) PREFIX=/usr SHAREDIR=/usr/share/misc ZLIB=yes
make PREFIX=/usr SHAREDIR=/usr/share/misc ZLIB=yes DESTDIR="$MEOW_STAGE" install
