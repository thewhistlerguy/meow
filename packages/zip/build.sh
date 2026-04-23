#!/bin/bash
# build.sh — zip
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
make -f unix/Makefile -j$(nproc) generic
install -Dm755 zip    "$MEOW_STAGE/usr/bin/zip"
install -Dm755 zipcloak "$MEOW_STAGE/usr/bin/zipcloak"
install -Dm755 zipnote  "$MEOW_STAGE/usr/bin/zipnote"
install -Dm755 zipsplit "$MEOW_STAGE/usr/bin/zipsplit"
install -Dm644 man/zip.1 "$MEOW_STAGE/usr/share/man/man1/zip.1"
