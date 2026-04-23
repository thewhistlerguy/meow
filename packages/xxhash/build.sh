#!/bin/bash
# build.sh — xxhash
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
make -j$(nproc) PREFIX=/usr
make PREFIX=/usr DESTDIR="$MEOW_STAGE" install
