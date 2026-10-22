#!/bin/bash
# AryaLinux package build
# ccache — ccache-4.14.2
# Built from the upstream release. zstd and xxhash are unpacked for CMake so the build does not fetch them.
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

echo "=== ccache-4.14.2 ==="
cd "$ARYA_SOURCES"

ccache_archive="ccache-4.14.2.tar.xz"
zstd_archive="zstd-1.5.7.tar.gz"
xxhash_archive="v0.8.3.tar.gz"
for archive in "$ccache_archive" "$zstd_archive" "$xxhash_archive"; do
    if [[ ! -f "$archive" ]]; then
        echo "Missing source archive: $ARYA_SOURCES/$archive" >&2
        exit 1
    fi
done

ccache_srcdir=$(get_srcdir "$ccache_archive")
zstd_srcdir=$(get_srcdir "$zstd_archive")
xxhash_srcdir=$(get_srcdir "$xxhash_archive")
rm -rf "$ccache_srcdir" "$zstd_srcdir" "$xxhash_srcdir"
extract_archive "$ccache_archive"
extract_archive "$zstd_archive"
extract_archive "$xxhash_archive"
cd "$ccache_srcdir"

mkdir build &&
cd    build &&

cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_INSTALL_SYSCONFDIR=/etc \
      -D ENABLE_TESTING=OFF \
      -D ENABLE_DOCUMENTATION=OFF \
      -D HTTP_STORAGE_BACKEND=OFF \
      -D REDIS_STORAGE_BACKEND=OFF \
      -D FETCHCONTENT_SOURCE_DIR_ZSTD="$ARYA_SOURCES/$zstd_srcdir" \
      -D FETCHCONTENT_SOURCE_DIR_XXHASH="$ARYA_SOURCES/$xxhash_srcdir" \
      .. &&
make
make install

cd "$ARYA_SOURCES"
rm -rf "$ccache_srcdir" "$zstd_srcdir" "$xxhash_srcdir"
