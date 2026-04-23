#!/bin/bash
# build.sh — unzip
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
make -f unix/Makefile -j$(nproc) generic
install -Dm755 unzip  "$MEOW_STAGE/usr/bin/unzip"
install -Dm755 unzipsfx "$MEOW_STAGE/usr/bin/unzipsfx"
install -Dm755 funzip "$MEOW_STAGE/usr/bin/funzip"
install -Dm644 man/unzip.1 "$MEOW_STAGE/usr/share/man/man1/unzip.1"
