#!/bin/bash
# build.sh — git
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --with-gitconfig=/etc/gitconfig     --with-openssl     --with-libpcre2     --with-curl     --with-expat
make -j$(nproc) all
make DESTDIR="$MEOW_STAGE" install
