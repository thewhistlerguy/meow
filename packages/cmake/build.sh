#!/bin/bash
# build.sh — cmake
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./bootstrap     --prefix=/usr     --system-libs     --mandir=/share/man     --no-system-jsoncpp     --no-system-cppdap     --no-system-librhash     --docdir=/share/doc/cmake-${MEOW_VER}
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
