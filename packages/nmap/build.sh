#!/bin/bash
# build.sh — nmap
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --with-openssl=/usr     --with-libpcap=/usr     --with-libpcre=/usr     --with-zlib=/usr     --without-zenmap     --without-ncat     --without-ndiff
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
