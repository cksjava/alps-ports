#!/bin/bash
# AryaLinux package build
# pcmanfm-qt — pcmanfm-qt-2.4.0
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

echo "=== pcmanfm-qt-2.4.0 ==="
cd "$ARYA_SOURCES"
tarball="pcmanfm-qt-2.4.0.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

if [   -e /opt/kf6/lib/libLayerShellQtInterface.so -a \
     ! -e /usr/lib/libLayerShellQtInterface.so ]; then

    ln -sv /opt/kf6/lib/libLayerShellQtInterface.so \
           /usr/lib/libLayerShellQtInterface.so
fi
mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      ..                           &&
make
make install
sed -e '/Categories=/s/=/=System;FileTools;/' \
    -e '/Name=/s/=.*/=File Manager PCManFM-Qt'/ \
    -i /usr/share/applications/pcmanfm-qt.desktop

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

