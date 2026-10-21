#!/bin/bash
# AryaLinux package build
# gst-plugins-rs — gst-plugins-rs-1.28.6
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

echo "=== gst-plugins-rs-1.28.6 ==="
cd "$ARYA_SOURCES"
tarball="gst-plugins-rs-gstreamer-1.28.6.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

cargo build --package gst-plugin-dav1d --release
install -vm755 target/release/libgstdav1d.so /usr/lib/gstreamer-1.0
cargo build --package gst-plugin-gtk4 --release
install -vm755 target/release/libgstgtk4.so /usr/lib/gstreamer-1.0

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

