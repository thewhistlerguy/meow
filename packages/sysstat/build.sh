#!/bin/bash
# build.sh — sysstat
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc     --disable-documentation     sa_lib_dir=/usr/lib/sa     sa_dir=/var/log/sysstat     conf_dir=/etc/sysstat
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
