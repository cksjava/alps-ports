#!/bin/bash
# AryaLinux package build
# btrfs-progs — btrfs-progs-7.1
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

echo "=== btrfs-progs-7.1 ==="
cd "$ARYA_SOURCES"
tarball="btrfs-progs-v7.1.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

./configure --prefix=/usr           \
            --disable-static        \
            --disable-documentation &&
make
make fssum
rm -rf tests/fsck-tests/074-raid56-read
rm -rf tests/mkfs-tests/010-minimal-size
rm -rf tests/mkfs-tests/042-rootdir-contents
rm -rf tests/misc-tests/041-subvolume-delete-during-send
rm -rf tests/fuzz-tests/010-simple-sb
make install
for i in 5 8; do
   install Documentation/*.$i /usr/share/man/man$i
done

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

