#!/bin/bash
# build.sh — tcl
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
cd unix
./configure     --prefix=/usr     --mandir=/usr/share/man     $([ $(uname -m) = x86_64 ] && echo --enable-64bit)
make -j$(nproc)
sed -e "s|/unix/pkgs|/lib|;s|$(pwd)|/usr/lib/tcl8.6|" -i tclConfig.sh
sed -e "s|$(pwd)/unix/|/usr/lib/|" -i tclConfig.sh
make DESTDIR="$MEOW_STAGE" install
make DESTDIR="$MEOW_STAGE" install-private-headers
ln -sf tclsh8.6 "$MEOW_STAGE/usr/bin/tclsh"
