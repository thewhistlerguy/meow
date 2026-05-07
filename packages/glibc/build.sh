#!/bin/bash
# build.sh for glibc 2.42
# glibc MUST be built in a separate build directory (never in the source tree).
# The meow build system is expected to run this script from the extracted
# source directory; we create a sibling build dir ourselves.
set -euo pipefail

SRC_DIR="$(pwd)"
BUILD_DIR="${SRC_DIR}/../glibc-build"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# ----- Configure -----
"${SRC_DIR}/configure" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib/glibc \
    --with-headers=/usr/include \
    --enable-kernel=4.14 \
    --enable-stack-protector=strong \
    --enable-bind-now \
    --disable-werror \
    --disable-profile \
    --disable-nscd \
    --with-pkgversion="Rockhopper glibc ${MEOW_VERSION}" \
    libc_cv_slibdir=/usr/lib \
    libc_cv_rtlddir=/usr/lib

# ----- Build -----
make -j"$(nproc)"

# ----- Minimal sanity check -----
# Build and run a trivial C program against the just-built libc to catch
# catastrophic breakage early.
echo '#include <stdio.h>
int main(void) { puts("glibc self-test OK"); return 0; }' > /tmp/_glibc_test.c

gcc /tmp/_glibc_test.c \
    -Wl,--dynamic-linker="${BUILD_DIR}/elf/ld-linux-x86-64.so.2" \
    -Wl,-rpath="${BUILD_DIR}" \
    -o /tmp/_glibc_test

/tmp/_glibc_test || { echo "ERROR: glibc self-test failed"; exit 1; }
rm -f /tmp/_glibc_test.c /tmp/_glibc_test

echo "glibc build completed successfully."
