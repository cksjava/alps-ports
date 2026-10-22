#!/bin/bash
# AryaLinux package build
# dtc — dtc-1.8.1
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

echo "=== dtc-1.8.1 ==="
cd "$ARYA_SOURCES"
tarball="dtc-1.8.1.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

mkdir build &&
cd    build &&

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      --default-library=shared \
      -D python=disabled       &&
ninja
ninja install
pushd ../Documentation
  latexmk -bibtex --pdf dtc-paper &&
  latexmk -bibtex --pdf dtc-paper -c
popd
cp -R ../Documentation -T /usr/share/doc/dtc-1.8.1
pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir ..
pip3 install --no-index --find-links dist --no-user libfdt

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

