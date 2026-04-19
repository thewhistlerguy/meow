# packages/vim/build.sh
set -euo pipefail
./configure \
    --prefix=/usr \
    --with-features=huge \
    --enable-multibyte \
    --disable-gui \
    --without-x \
    --with-tlib=ncursesw
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
# vi symlink
ln -sf vim "$MEOW_STAGE/usr/bin/vi"
strip --strip-unneeded "$MEOW_STAGE/usr/bin/vim"
