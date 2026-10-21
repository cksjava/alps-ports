#!/bin/bash
# AryaLinux package build
# slang — slang-2.3.3
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

echo "=== slang-2.3.3 ==="
cd "$ARYA_SOURCES"
tarball="slang-2.3.3.tar.bz2"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --with-readline=gnu &&
make -j1 RPATH=
make install_doc_dir=/usr/share/doc/slang-2.3.3   \
     SLSH_DOC_DIR=/usr/share/doc/slang-2.3.3/slsh \
     RPATH= install

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

