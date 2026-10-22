#!/bin/bash
# AryaLinux package build
# kwindowsystem — kwindowsystem-6.29.0
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

echo "=== kwindowsystem-6.29.0 ==="
cd "$ARYA_SOURCES"
tarball="kwindowsystem-6.29.0.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

mkdir build
cd    build
cmake -D CMAKE_INSTALL_PREFIX=$KF6_PREFIX \
-D CMAKE_INSTALL_LIBEXECDIR=libexec \
-D CMAKE_PREFIX_PATH=$QT6DIR        \
-D CMAKE_SKIP_INSTALL_RPATH=ON      \
-D CMAKE_BUILD_TYPE=Release         \
-D BUILD_TESTING=OFF                \
-D BUILD_PYTHON_BINDINGS=OFF        \
-W no-author ..
make
make install
/sbin/ldconfig

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

