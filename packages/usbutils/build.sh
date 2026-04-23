#!/bin/bash
# build.sh — usbutils
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure --prefix=/usr --datadir=/usr/share/misc
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
