# packages/nano/build.sh
set -euo pipefail
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --enable-utf8 \
    --disable-mouse
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
strip --strip-unneeded "$MEOW_STAGE/usr/bin/nano"
