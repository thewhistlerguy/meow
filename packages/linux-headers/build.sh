#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

make ARCH=x86_64 INSTALL_HDR_PATH=$MEOW_STAGE/usr headers_install
