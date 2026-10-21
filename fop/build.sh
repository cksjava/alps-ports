#!/bin/bash
# AryaLinux package build
# fop — fop-2.11
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

echo "=== fop-2.11 ==="
cd "$ARYA_SOURCES"
tarball="fop-2.11-src.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

python3 -m zipfile -e ../offo-hyphenation.zip . &&
cp offo-hyphenation/hyph/* fop/hyph &&
rm -rf offo-hyphenation
tar -xf ../apache-maven-3.9.12-bin.tar.gz -C /tmp
cd fop &&

LC_ALL=en_US.UTF-8                      \
PATH=$PATH:/tmp/apache-maven-3.9.12/bin \
ant package javadocs &&

mv build/javadocs .
install -v -d -m755 -o root -g root          /opt/fop-2.11 &&
cp -vR build conf examples fop* javadocs lib /opt/fop-2.11 &&
chmod a+x /opt/fop-2.11/fop                                &&
ln -v -sfn fop-2.11 /opt/fop
rm -rf /tmp/apache-maven-3.9.12

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

