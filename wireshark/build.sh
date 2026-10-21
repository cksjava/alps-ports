#!/bin/bash
# AryaLinux package build
# wireshark — Wireshark-4.6.8
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

echo "=== Wireshark-4.6.8 ==="
cd "$ARYA_SOURCES"
tarball="wireshark-4.6.8.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

groupadd -g 62 wireshark
mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/wireshark-4.6.8 \
      -G Ninja \
      .. &&
ninja
ninja install &&

install -v -m755 -d /usr/share/doc/wireshark-4.6.8 &&
install -v -m644    ../README.linux ../doc/README.* ../doc/randpkt.txt \
                    /usr/share/doc/wireshark-4.6.8 &&

pushd /usr/share/doc/wireshark-4.6.8 &&
   for FILENAME in ../../wireshark/*.html; do
      ln -s -v -f $FILENAME .
   done &&
popd
unset FILENAME
chown -v root:wireshark /usr/bin/tshark &&
chmod -v 6550 /usr/bin/tshark

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

