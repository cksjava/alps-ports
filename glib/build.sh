#!/bin/bash
# AryaLinux package build
# glib — GLib-2.88.3
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

echo "=== GLib-2.88.3 ==="
cd "$ARYA_SOURCES"

patch -Np1 -i ../glib-skip_warnings-1.patch
if [ -e /usr/include/glib-2.0 ]; then
    rm -rf /usr/include/glib-2.0.old &&
    mv -vf /usr/include/glib-2.0{,.old}
fi
mkdir build &&
cd    build &&

meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D introspection=disabled \
      -D glib_debug=disabled    \
      -D man-pages=enabled      \
      -D sysprof=disabled       &&
ninja
ninja install
tar xf ../../gobject-introspection-1.86.0.tar.xz &&

meson setup gobject-introspection-1.86.0 gi-build \
            --prefix=/usr --buildtype=release     &&
ninja -C gi-build
ninja -C gi-build install
meson configure -D introspection=enabled &&
ninja
sed "/docs_dir =/s|$| / 'glib-' + meson.project_version()|" \
    -i ../docs/reference/meson.build                        &&
meson configure -D documentation=true                       &&
ninja
ninja install
