#!/bin/bash
# build.sh — man-pages
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
# man-pages has no configure; just install
make prefix=/usr DESTDIR="$MEOW_STAGE" install
