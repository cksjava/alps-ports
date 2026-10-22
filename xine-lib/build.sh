#!/bin/bash
# AryaLinux package build
# xine-lib — xine-lib-1.2.13
# Instructions follow the book. Test-suite commands are omitted.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

# shellcheck disable=SC1091
source /var/lib/alps/env.sh
# shellcheck disable=SC1091
source /var/lib/alps/alpslib.sh

: "${ARYA_SOURCES:=/sources}"
: "${ARYA_ROOT:=/aryalinux-builder}"
if [[ ! -d "$ARYA_SOURCES" && -n "${LFS:-}" && -d "$LFS/sources" ]]; then
    ARYA_SOURCES="$LFS/sources"
fi

_arya_here=$(cd "$(dirname "$0")" && pwd)
if [[ -r "$_arya_here/../../lib/idempotent.sh" ]]; then
    # shellcheck disable=SC1091
    source "$_arya_here/../../lib/idempotent.sh"
fi

echo "=== xine-lib-1.2.13 ==="
cd "$ARYA_SOURCES"
tarball="xine-lib-1.2.13.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

patch -Np1 -i ../xine-lib-1.2.13-upstream_fixes-1.patch
patch -Np1 -i ../xine-lib-1.2.13-gcc15_fixes-1.patch
patch -Np1 -i ../xine-lib-1.2.13-ffmpeg8.patch
./configure --prefix=/usr          \
            --disable-vcd          \
            --disable-w32dll       \
            --with-external-dvdnav \
            --docdir=/usr/share/doc/xine-lib-1.2.13 &&
make
doxygen doc/Doxyfile
make install
install -v -m755 -d /usr/share/doc/xine-lib-1.2.13/api &&
install -v -m644    doc/api/* \
                    /usr/share/doc/xine-lib-1.2.13/api

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

