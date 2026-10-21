#!/bin/bash
# AryaLinux package build
# sane — SANE-1.4.0
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

echo "=== SANE-1.4.0 ==="
cd "$ARYA_SOURCES"
tarball="sane-backends-1.4.0.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

groupadd -g 70 scanner
usermod -G scanner -a username
sg scanner -c "                                 \
PYTHON=python3 ./configure --prefix=/usr        \
                           --sysconfdir=/etc    \
                           --localstatedir=/var \
                           --with-lockdir=/run/lock \
                           --docdir=/usr/share/doc/sane-backends-1.4.0" &&
make
make install                                         &&
install -m 644 -v tools/udev/libsane.rules           \
                  /etc/udev/rules.d/65-scanner.rules &&
mkdir -p          /run/lock/sane &&
chgrp -v scanner  /run/lock/sane

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

