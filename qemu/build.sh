#!/bin/bash
# AryaLinux package build
# qemu — qemu-11.1.1
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

echo "=== qemu-11.1.1 ==="
cd "$ARYA_SOURCES"
tarball="qemu-11.1.1.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

if [ $(uname -m) = i686 ]; then
   QEMU_ARCH=i386-softmmu
else
   QEMU_ARCH=x86_64-softmmu
fi

mkdir -vp build &&
cd        build &&

../configure --prefix=/usr            \
             --sysconfdir=/etc        \
             --localstatedir=/var     \
             --target-list=$QEMU_ARCH \
             --audio-drv-list=alsa    \
             --disable-download       \
             --disable-pa             \
             --enable-slirp           \
             --docdir=/usr/share/doc/qemu-11.1.1 &&

unset QEMU_ARCH &&

make
make install
chgrp kvm  /usr/libexec/qemu-bridge-helper &&
chmod 4750 /usr/libexec/qemu-bridge-helper
ln -sv qemu-system-`uname -m` /usr/bin/qemu

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

