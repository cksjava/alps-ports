#!/bin/bash
# AryaLinux package build
# cdrtools — Cdrtools-3.02a09
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

echo "=== Cdrtools-3.02a09 ==="
cd "$ARYA_SOURCES"
tarball="cdrtools-3.02a09.tar.bz2"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

sed -i 's|/opt/schily|/usr|g'           DEFAULTS/Defaults.linux &&
sed -i 's|DEFINSGRP=.*|DEFINSGRP=root|' DEFAULTS/Defaults.linux &&
sed -i 's|INSDIR=\s*sbin|INSDIR=bin|'   rscsi/Makefile          &&

export GMAKE_NOWARN=true &&
export CFLAGS="$CFLAGS -std=gnu89 -fno-strict-aliasing" &&

make -j1 INS_BASE=/usr  \
         DEFINSUSR=root \
         DEFINSGRP=root \
         VERSION_OS="LinuxFromScratch"
GMAKE_NOWARN=true &&

make INS_BASE=/usr    \
     DEFINSUSR=root   \
     DEFINSGRP=root   \
     MANSUFF_LIB=3cdr \
     install          &&

install -v -m755 -d /usr/share/doc/cdrtools-3.02a09 &&
install -v -m644 README.* READMEs/* ABOUT doc/*.ps  \
                    /usr/share/doc/cdrtools-3.02a09

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

