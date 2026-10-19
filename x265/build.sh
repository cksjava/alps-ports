#!/bin/bash
# AryaLinux package build
# x265 — x265-4.2
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

echo "=== x265-4.2 ==="
cd "$ARYA_SOURCES"
tarball="x265_4.2.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

sed -i 's/FORMAT_ELF/UNIX64 \&\& FORMAT_ELF/' source/common/x86/cpu-a.asm
mkdir bld &&
cd    bld &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D GIT_ARCHETYPE=1           \
      -W no-author                 \
      ../source                    &&
make
make install &&
rm -vf /usr/lib/libx265.a

cd "$ARYA_SOURCES"
rm -rf "$srcdir"
