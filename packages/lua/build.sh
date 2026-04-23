#!/bin/bash
# build.sh — lua
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
make -j$(nproc) INSTALL_TOP=/usr linux
make INSTALL_TOP=/usr INSTALL_MAN=/usr/share/man/man1 TO_BIN="lua luac" DESTDIR="$MEOW_STAGE" install
