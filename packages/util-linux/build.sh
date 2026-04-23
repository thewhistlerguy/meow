#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

./configure \
    --bindir=/usr/bin \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --localstatedir=/var \
    --runstatedir=/run \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-static \
    --without-python

make -j$(nproc)

make DESTDIR="$MEOW_STAGE" install
