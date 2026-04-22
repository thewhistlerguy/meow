#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

install -d "$MEOW_STAGE/etc"
cp services protocols "$MEOW_STAGE/etc/"
