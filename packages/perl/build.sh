#!/bin/bash
# build.sh — called by meow build
set -euo pipefail

make -j$(nproc)

sh Configure -des                      -Dprefix=/usr                         -Dvendorprefix=/usr                   -Dprivlib=/usr/lib/perl5/5.38/core_perl     -Darchlib=/usr/lib/perl5/5.38/core_perl     -Dsitelib=/usr/lib/perl5/5.38/site_perl     -Dsitearch=/usr/lib/perl5/5.38/site_perl     -Dman1dir=/usr/share/man/man1         -Dman3dir=/usr/share/man/man3         -Dpager="/usr/bin/less -isR"          -Duseshrplib                          -Dusethreads
make -j$(nproc)
make DESTDIR="$MEOW_STAGE" install
