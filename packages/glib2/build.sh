#!/bin/bash
# build.sh — glib2
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
mkdir build && cd build
meson setup     --prefix=/usr     --buildtype=release     -D introspection=disabled     -D man-pages=disabled     ..
ninja -j$(nproc)
DESTDIR="$MEOW_STAGE" ninja install
