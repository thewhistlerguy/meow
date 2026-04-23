#!/bin/bash
# build.sh — dhcpcd
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc     --runstatedir=/run/dhcpcd
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install

# runit service
install -Dm755 /dev/stdin "$MEOW_STAGE/etc/sv/dhcpcd/run" << 'EOF'
#!/bin/sh
exec /usr/sbin/dhcpcd -B -q
EOF
