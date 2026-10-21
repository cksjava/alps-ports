#!/bin/bash
# AryaLinux package build
# tcsh — Tcsh-6.24.16
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

echo "=== Tcsh-6.24.16 ==="
cd "$ARYA_SOURCES"
tarball="tcsh-6.24.16.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

./configure --prefix=/usr &&
make
make install install.man &&

ln -v -sf tcsh   /bin/csh &&
ln -v -sf tcsh.1 /usr/share/man/man1/csh.1

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

