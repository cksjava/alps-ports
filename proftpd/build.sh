#!/bin/bash
# AryaLinux package build
# proftpd — ProFTPD-1.3.9b
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

echo "=== ProFTPD-1.3.9b ==="
cd "$ARYA_SOURCES"
tarball="proftpd-1.3.9b.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

groupadd -g 46 proftpd                             &&
useradd -c proftpd -d /srv/ftp -g proftpd \
        -s /usr/bin/proftpdshell -u 46 proftpd     &&

install -v -d -m775 -o proftpd -g proftpd /srv/ftp &&
ln -v -s /usr/bin/false /usr/bin/proftpdshell      &&
echo /usr/bin/proftpdshell >> /etc/shells
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/run &&
make
make install                                   &&
install -d -m755 /usr/share/doc/proftpd-1.3.9b &&
cp -Rv doc/*     /usr/share/doc/proftpd-1.3.9b

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

