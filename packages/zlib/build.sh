# packages/zlib/build.sh
set -euo pipefail
./configure --prefix=/usr
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
strip --strip-unneeded "$MEOW_STAGE/usr/lib/libz.so"
