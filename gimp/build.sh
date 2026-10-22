#!/bin/bash
# AryaLinux package build
# gimp — Gimp-3.2.4
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

echo "=== Gimp-3.2.4 ==="
cd "$ARYA_SOURCES"
tarball="gimp-3.2.4.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

rm -rf /usr/{lib,share}/gimp/3.0 &&
rm -f  /usr/share/gir-1.0/Gimp-3.0.gir &&
rm -f  /usr/lib/girepository-1.0/Gimp-3.0.typelib &&
rm -f  /usr/lib/libgimp*-3.0.so*
patch -Np1 -i build/macos/patches/0001-build-macos-Do-not-require-gexiv2-0.14-on-homebrew.patch
mkdir gimp-build &&
cd    gimp-build &&

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D headless-tests=disabled &&
ninja
ninja install
gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
update-desktop-database -q
make
make install &&
chown -R root:root /usr/share/gimp/3.0/help

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

