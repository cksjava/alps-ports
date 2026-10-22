#!/bin/bash
# AryaLinux package build
# libevent — libevent-2.1.13
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

echo "=== libevent-2.1.13 ==="
cd "$ARYA_SOURCES"
tarball="libevent-2.1.13-stable.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

sed -i 's/python/&3/' event_rpcgen.py
./configure --prefix=/usr --disable-static &&
make
make install
install -v -m755 -d /usr/share/doc/libevent-2.1.13/api &&
cp      -v -R       html/* \
                    /usr/share/doc/libevent-2.1.13/api

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

