#!/bin/bash
# AryaLinux package build
# libassuan — libassuan-3.0.2
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

echo "=== libassuan-3.0.2 ==="
cd "$ARYA_SOURCES"
tarball="libassuan-3.0.2.tar.bz2"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

./configure --prefix=/usr &&
make                      &&

make -C doc html                                                       &&
makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi &&
makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi
make install &&

install -v -dm755   /usr/share/doc/libassuan-3.0.2/html &&
install -v -m644 doc/assuan.html/* \
                    /usr/share/doc/libassuan-3.0.2/html &&
install -v -m644 doc/assuan_nochunks.html \
                    /usr/share/doc/libassuan-3.0.2      &&
install -v -m644 doc/assuan.{txt,texi} \
                    /usr/share/doc/libassuan-3.0.2

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

