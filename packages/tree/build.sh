#!/bin/bash
# build.sh — tree
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
# tree uses a simple Makefile, no configure
make -j$(nproc) CC=gcc CFLAGS="-O2 -Wall" PREFIX=/usr
make PREFIX=/usr DESTDIR="$MEOW_STAGE" install
