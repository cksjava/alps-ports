#!/bin/bash
# AryaLinux package build
# tigervnc — Tigervnc-1.16.2
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

echo "=== Tigervnc-1.16.2 ==="
cd "$ARYA_SOURCES"
tarball="tigervnc-1.16.2.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

patch -Np1 -i ../tigervnc-1.16.2-configuration_fixes-1.patch
grep -rl _digest | xargs sed -Ei '/digest/s/([^,]*),.*,(.*)/\1,\2/' &&
grep -rl _DIGEST | xargs sed -i '/DIGEST/s/, 16//'
# Put code in place
mkdir -p unix/xserver &&
tar -xf ../xorg-server-21.1.24.tar.xz \
    --strip-components=1              \
    -C unix/xserver                   &&

pushd unix/xserver                             &&
  patch -Np1 -i ../xserver21.patch             &&
popd                                           &&

# Build viewer
cmake -G "Unix Makefiles"          \
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -W no-author .               &&
make                               &&

# Build server
pushd unix/xserver &&
  autoreconf -fiv  &&

  CPPFLAGS="-I/usr/include/drm"       \
  ./configure $XORG_CONFIG            \
      --disable-xorg        --disable-xnest      --disable-xvfb        \
      --disable-xwin        --disable-xephyr     --disable-kdrive      \
      --disable-devel-docs  --disable-config-hal --disable-config-udev \
      --disable-unit-tests  --disable-selective-werror                 \
      --disable-static      --enable-dri3        --disable-dri         \
      --without-dtrace      --enable-dri2        --enable-glx          \
      --with-pic &&
  make           &&
popd
# Install viewer
make install &&
mv  /usr/share/doc/tigervnc /usr/share/doc/tigervnc-1.16.2

# Install server
( cd unix/xserver/hw/vnc && make install )                     &&
cp  unix/vncserver/vncserver@.service /usr/lib/systemd/system/ &&
install -m755 unix/vncserver/vncsession-start /usr/libexec/    &&

[ -e /usr/bin/Xvnc ] || ln -svf $XORG_PREFIX/bin/Xvnc /usr/bin/Xvnc

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

