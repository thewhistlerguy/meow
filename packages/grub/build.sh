#!/bin/bash
# build.sh — grub
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc     --disable-efiemu     --enable-grub-mkfont     --with-platform=efi     --target=x86_64     --disable-werror
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
