#!/bin/bash
# AryaLinux package build
# freerdp — FreeRDP-3.31.0
# Instructions follow the book. Test-suite commands are omitted.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

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

echo "=== FreeRDP-3.31.0 ==="
cd "$ARYA_SOURCES"
tarball="FreeRDP-3.31.0.tar.gz"
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

cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D CMAKE_BUILD_TYPE=Release    \
      -D WITH_CAIRO=ON               \
      -D WITH_CLIENT_SDL=OFF         \
      -D WITH_DSP_FFMPEG=ON          \
      -D WITH_FFMPEG=ON              \
      -D WITH_PCSC=OFF               \
      -D WITH_SERVER=ON              \
      -D WITH_SERVER_CHANNELS=ON     \
      -D DOCBOOKXSL_DIR=/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 \
      -W no-author                   \
      -G Ninja ..                    &&
ninja
ninja install

cd "$ARYA_SOURCES"
rm -rf "$srcdir"
