#!/bin/bash
# build.sh — man-db
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}     --sysconfdir=/etc     --disable-setuid     --enable-cache-owner=bin     --with-browser=/usr/bin/lynx     --with-vgrind=/usr/bin/vgrind     --with-grap=/usr/bin/grap     --with-systemdtmpfilesdir=''
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
