#!/bin/bash
# build.sh — groff
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
PAGE=letter ./configure --prefix=/usr
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
