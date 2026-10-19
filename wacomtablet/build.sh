#!/bin/bash
# AryaLinux package build
# wacomtablet — wacomtablet-6.7.4
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

echo "=== wacomtablet-6.7.4 ==="
cd "$ARYA_SOURCES"

as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root
line='6b25901d6278559630a849b1e10a1fcc  wacomtablet-6.7.4.tar.xz'
    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    pkg=$(       echo $file|sed 's|^.*/||')    # Remove directory
    name=$(      echo $pkg |sed 's|-6.*$||')   # Isolate package name
    packagedir=$(echo $pkg |sed 's|\.tar.*||') # Source directory

    tar -xf $file
    pushd $packagedir

       mkdir build
       cd    build

       cmake -D CMAKE_INSTALL_PREFIX=$KF6_PREFIX \
             -D CMAKE_INSTALL_LIBEXECDIR=libexec \
             -D CMAKE_BUILD_TYPE=Release         \
             -D BUILD_QT5=OFF                    \
             -D BUILD_TESTING=OFF                \
             -W no-author ..  &&

        make
        as_root make install
    popd


    as_root rm -rf $packagedir
    as_root /sbin/ldconfig
# Setup xsessions (X11 sessions)
install -dvm 755 /usr/share/xsessions
cd /usr/share/xsessions

[ -e plasma.desktop ] ||
ln -sfv $KF6_PREFIX/share/xsessions/plasmax11.desktop 

# Setup wayland-sessions 
install -dvm 755 /usr/share/wayland-sessions
cd /usr/share/wayland-sessions

[ -e plasmawayland.desktop ] ||
ln -sfv $KF6_PREFIX/share/wayland-sessions/plasma.desktop

# Setup xdg-desktop-portal
install -dvm 755 /usr/share/xdg-desktop-portal
cd /usr/share/xdg-desktop-portal 

[ -e kde-portals.conf ] ||
ln -sfv $KF6_PREFIX/share/xdg-desktop-portal/kde-portals.conf

# Setup kde portal
install -dvm 755 /usr/share/xdg-desktop-portal/portals
cd /usr/share/xdg-desktop-portal/portals

[ -e kde.portal ] ||
ln -sfv $KF6_PREFIX/share/xdg-desktop-portal/portals/kde.portal
