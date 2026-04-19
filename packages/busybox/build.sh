# packages/busybox/build.sh
set -euo pipefail
# Use defconfig then tweak for musl + static
make defconfig
# Static binary linked against musl
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's|CONFIG_CROSS_COMPILER_PREFIX=""|CONFIG_CROSS_COMPILER_PREFIX=""|' .config
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
strip --strip-unneeded "$MEOW_STAGE/bin/busybox"
