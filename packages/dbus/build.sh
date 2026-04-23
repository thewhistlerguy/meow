#!/bin/bash
# build.sh — dbus
# Env vars: MEOW_WORK  MEOW_STAGE  MEOW_NAME  MEOW_VER  MEOW_REL
set -euo pipefail

set -euo pipefail
./configure     --prefix=/usr     --sysconfdir=/etc     --localstatedir=/var     --runstatedir=/run     --disable-static     --disable-doxygen-docs     --disable-xml-docs     --docdir=/usr/share/doc/${MEOW_NAME}-${MEOW_VER}     --with-system-socket=/run/dbus/system_bus_socket
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install

# Create dbus user/group entries (shadow will handle actual creation at install time)
install -Dm755 /dev/stdin "$MEOW_STAGE/usr/lib/meow/post-install/dbus.sh" << 'EOF'
#!/bin/sh
groupadd -r -g 18 messagebus 2>/dev/null || true
useradd -c "D-Bus Message Daemon User" -d /var/run/dbus     -u 18 -g messagebus -s /bin/false messagebus 2>/dev/null || true
EOF
