# packages/musl/build.sh
set -euo pipefail
./configure \
    --prefix=/usr \
    --syslibdir=/lib
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
# Symlink ldd
ln -sf /lib/libc.so "$MEOW_STAGE/usr/bin/ldd"
