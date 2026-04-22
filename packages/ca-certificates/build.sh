#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

install -d "$MEOW_STAGE/etc/ssl/certs"
install -d "$MEOW_STAGE/usr/share/ca-certificates"
cp -r * "$MEOW_STAGE/usr/share/ca-certificates/" 2>/dev/null || true
update-ca-certificates 2>/dev/null || true
