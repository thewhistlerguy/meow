# packages/ncurses/build.sh
set -euo pipefail
./configure \
    --prefix=/usr \
    --with-shared \
    --without-debug \
    --without-normal \
    --with-cxx-shared \
    --enable-widec \
    --disable-stripping
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
# Non-wide compat symlinks (a lot of software expects libncurses not libncursesw)
for lib in ncurses form panel menu; do
    ln -sf lib${lib}w.so "$MEOW_STAGE/usr/lib/lib${lib}.so"
done
strip --strip-unneeded "$MEOW_STAGE"/usr/lib/lib*.so
