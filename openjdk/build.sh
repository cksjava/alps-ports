#!/bin/bash
# AryaLinux package build
# openjdk — OpenJDK-21.0.12.1
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

echo "=== OpenJDK-21.0.12.1 ==="
cd "$ARYA_SOURCES"
tarball="jdk-21.0.12.1-ga.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

tar -xf ../jtreg-8.2.1+1.tar.gz
export MAKEFLAGS_HOLD=$MAKEFLAGS            &&
unset  JAVA_HOME                            &&
unset  CLASSPATH                            &&
unset  MAKEFLAGS                            &&
bash configure --enable-unlimited-crypto    \
               --disable-warnings-as-errors \
               --with-stdc++lib=dynamic     \
               --with-giflib=system         \
               --with-harfbuzz=system       \
               --with-jtreg=$PWD/jtreg      \
               --with-lcms=system           \
               --with-libjpeg=system        \
               --with-libpng=system         \
               --with-zlib=system           \
               --with-version-build="1"     \
               --with-version-pre=""        \
               --with-version-opt=""        \
               --with-jobs=$(nproc)         \
               --with-cacerts-file=/etc/pki/tls/java/cacerts &&
make images
install -vdm755 /opt/jdk-21.0.12.1+1             &&
cp -Rv build/*/images/jdk/* /opt/jdk-21.0.12.1+1 &&
chown -R root:root /opt/jdk-21.0.12.1+1          &&
for s in 16 24 32 48; do
  install -vDm644 src/java.desktop/unix/classes/sun/awt/X11/java-icon${s}.png \
                  /usr/share/icons/hicolor/${s}x${s}/apps/java.png
done
find /opt/jdk-21.0.12.1+1 -name *.debuginfo -delete
export MAKEFLAGS=$MAKEFLAGS_HOLD &&
unset  MAKEFLAGS_HOLD
ln -v -nsf jdk-21.0.12.1+1 /opt/jdk

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

