#!/bin/bash
# AryaLinux package build
# bind-utilities — BIND Utilities-9.20.27
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

echo "=== BIND Utilities-9.20.27 ==="
cd "$ARYA_SOURCES"
tarball="bind-9.20.27.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

./configure --prefix=/usr --sysconfdir=/etc &&
make -C lib/isc      &&
make -C lib/dns      &&
make -C lib/ns       &&
make -C lib/isccfg   &&
make -C lib/isccc    &&
make -C bin/dig      &&
make -C bin/nsupdate &&
make -C bin/rndc
make -C lib/isc      install &&
make -C lib/dns      install &&
make -C lib/ns       install &&
make -C lib/isccfg   install &&
make -C lib/isccc    install &&
make -C bin/dig      install &&
make -C bin/nsupdate install &&
make -C bin/rndc     install &&
cp -v doc/man/{dig.1,host.1,nslookup.1,nsupdate.1} /usr/share/man/man1 &&
cp -v doc/man/rndc.8 /usr/share/man/man8

cd "$ARYA_SOURCES"
rm -rf "$srcdir"
