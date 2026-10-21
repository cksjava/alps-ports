#!/bin/bash
# AryaLinux package build
# gdb — GDB-17.2
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

echo "=== GDB-17.2 ==="
cd "$ARYA_SOURCES"
tarball="gdb-17.2.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

mkdir build &&
cd    build &&

../configure --prefix=/usr          \
             --with-system-readline \
             --with-system-zlib     \
             --with-python=/usr/bin/python3 &&
make
make -C gdb install &&
make -C gdbserver install
install -d /usr/share/doc/gdb-17.2 &&
rm -rf gdb/doc/doxy/xml &&
cp -Rv gdb/doc/doxy /usr/share/doc/gdb-17.2

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

