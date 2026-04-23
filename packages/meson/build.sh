#!/bin/bash
# build.sh — meson
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
python3 setup.py build
python3 setup.py install --prefix=/usr --root="$MEOW_STAGE"
