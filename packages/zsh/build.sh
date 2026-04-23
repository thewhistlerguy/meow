#!/bin/bash
# build.sh — zsh
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc/zsh     --enable-etcdir=/etc/zsh     --enable-zshenv=/etc/zsh/zshenv     --enable-zlogin=/etc/zsh/zlogin     --enable-zlogout=/etc/zsh/zlogout     --enable-zprofile=/etc/zsh/zprofile     --enable-zshrc=/etc/zsh/zshrc     --enable-multibyte     --enable-pcre     --enable-cap     --with-tcsetpgrp
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install

# Add zsh to /etc/shells
install -dm755 "$MEOW_STAGE/etc"
echo "/usr/bin/zsh" >> "$MEOW_STAGE/etc/shells" || true
