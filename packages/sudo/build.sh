#!/bin/bash
# build.sh — sudo
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --libexecdir=/usr/lib     --with-secure-path     --with-all-insults     --with-env-editor     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}     --with-passprompt="[sudo] password for %p: "
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install

# Ensure sudoers has sensible defaults
install -Dm440 /dev/stdin "$MEOW_STAGE/etc/sudoers" << 'EOF'
root ALL=(ALL:ALL) ALL
%wheel ALL=(ALL:ALL) ALL
EOF
