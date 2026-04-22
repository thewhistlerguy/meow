#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make make prefix=/usr lib=lib

make prefix=/usr lib=lib DESTDIR="$MEOW_STAGE" install
