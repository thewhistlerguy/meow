#!/bin/bash
# build.sh — pcre2
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}     --enable-unicode     --enable-jit     --enable-pcre2-16     --enable-pcre2-32     --enable-pcre2grep-libz     --enable-pcre2grep-libbz2     --enable-pcre2test-libreadline     --disable-static
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
