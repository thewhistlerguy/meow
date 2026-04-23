#!/bin/bash
# build.sh — ninja
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
python3 configure.py --bootstrap
install -Dm755 ninja "$MEOW_STAGE/usr/bin/ninja"
install -Dm644 doc/manual.asciidoc "$MEOW_STAGE/usr/share/doc/ninja/manual.asciidoc"
