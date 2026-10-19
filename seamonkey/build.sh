#!/bin/bash
# AryaLinux package build
# seamonkey — Seamonkey-2.53.24
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

echo "=== Seamonkey-2.53.24 ==="
cd "$ARYA_SOURCES"
tarball="seamonkey-2.53.24.source.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

(for i in {43..48}; do
   sed '/ZWJ/s/$/,CLASS_CHARACTER/' -i intl/lwbrk/LineBreaker.cpp || exit $?
done) &&

sed -i 's/icu-i18n/icu-uc &/' js/moz.configure
export PATH_PY311=/opt/python3.11/bin:$PATH &&
export MOZBUILD_STATE_PATH=${PWD}/mozbuild  &&
PATH=$PATH_PY311 AUTOCONF=true MACH_USE_SYSTEM_PYTHON=1 ./mach build
PATH=$PATH_PY311 MACH_USE_SYSTEM_PYTHON=1 ./mach install &&
chown -R 0:0 /usr/lib/seamonkey                          &&

cp -v $(find -name seamonkey.1 | head -n1) /usr/share/man/man1

cd "$ARYA_SOURCES"
rm -rf "$srcdir"
