#!/bin/bash
# build.sh — jq
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --disable-maintainer-mode     --with-oniguruma=builtin
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
