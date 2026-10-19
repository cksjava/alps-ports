#!/bin/bash
# AryaLinux package build
# kauth — kauth-6.29.0
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

echo "=== kauth-6.29.0 ==="
cd "$ARYA_SOURCES"

as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root
mv -v /opt/kf6 /opt/kf6.old                         &&
install -v -dm755           $KF6_PREFIX/{etc,share} &&
ln -sfv /etc/dbus-1         $KF6_PREFIX/etc         &&
ln -sfv /usr/share/dbus-1   $KF6_PREFIX/share       &&
ln -sfv /usr/share/polkit-1 $KF6_PREFIX/share       &&
install -v -dm755           $KF6_PREFIX/lib         &&
ln -sfv /usr/lib/systemd    $KF6_PREFIX/lib
line='ff94c0e5bbdaf953d4615106557e6074  kauth-6.29.0.tar.xz'
    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    pkg=$(echo $file|sed 's|^.*/||')          # Remove directory
    packagedir=$(echo $pkg|sed 's|\.tar.*||') # Package directory

    name=$(echo $pkg|sed 's|-6.*$||') # Isolate package name

    tar -xf $file
    pushd $packagedir

      # kapidox is a python module
      case $name in
        kapidox)
          pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
          as_root pip3 install --no-index --find-links dist --no-user kapidox
          popd
          rm -rf $packagedir
          continue
          ;;
      esac

      mkdir build
      cd    build

      cmake -D CMAKE_INSTALL_PREFIX=$KF6_PREFIX \
            -D CMAKE_INSTALL_LIBEXECDIR=libexec \
            -D CMAKE_PREFIX_PATH=$QT6DIR        \
            -D CMAKE_SKIP_INSTALL_RPATH=ON      \
            -D CMAKE_BUILD_TYPE=Release         \
            -D BUILD_TESTING=OFF                \
            -D BUILD_PYTHON_BINDINGS=OFF        \
            -W no-author ..
      make
      as_root make install
    popd

  as_root rm -rf $packagedir
  as_root /sbin/ldconfig
mv -v /opt/kf6 /opt/kf6-6.29.0
ln -sfvn kf6-6.29.0 /opt/kf6
