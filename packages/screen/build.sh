#!/bin/bash
# build.sh — screen
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --infodir=/usr/share/info     --mandir=/usr/share/man     --with-socket-dir=/run/screen     --with-pty-mode=0620     --with-pty-group=5     --with-sys-screenrc=/etc/screenrc     --with-logdir=/var/log/screen
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
