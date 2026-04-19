# packages/readline/build.sh
set -euo pipefail
./configure \
    --prefix=/usr \
    --with-curses \
    --disable-static
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
strip --strip-unneeded "$MEOW_STAGE"/usr/lib/lib*.so
