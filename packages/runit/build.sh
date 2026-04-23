#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

package/compile
package/check 2>/dev/null || true
for bin in runit runit-init chpst runsv runsvdir sv svlogd utmpset; do
    install -Dm755 "command/$bin" "$MEOW_STAGE/usr/sbin/$bin"
done
install -d "$MEOW_STAGE/etc/runit"
# Stage 1/2/3 scripts
cat > "$MEOW_STAGE/etc/runit/1" << 'STAGE1'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mkdir -p /dev/{pts,shm}
mount -t devpts devpts /dev/pts
mount -t tmpfs tmpfs /dev/shm
echo > /etc/runit/stopit
chmod 0 /etc/runit/stopit
STAGE1
cat > "$MEOW_STAGE/etc/runit/2" << 'STAGE2'
#!/bin/sh
exec env - PATH=/usr/bin:/usr/sbin runsvdir /etc/service
STAGE2
cat > "$MEOW_STAGE/etc/runit/3" << 'STAGE3'
#!/bin/sh
echo "System is coming down..."
STAGE3
chmod +x "$MEOW_STAGE/etc/runit/"{1,2,3}
