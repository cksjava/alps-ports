#!/bin/bash
# AryaLinux package build
# ffmpeg — FFmpeg-9.0.1
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

echo "=== FFmpeg-9.0.1 ==="
cd "$ARYA_SOURCES"
tarball="ffmpeg-9.0.1.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

patch -Np1 -i ../ffmpeg-9.0.1-chromium_method-1.patch
./configure --prefix=/usr        \
            --enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --disable-static     \
            --enable-shared      \
            --disable-debug      \
            --enable-libaom      \
            --enable-libass      \
            --enable-libfdk-aac  \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopus     \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libx264     \
            --enable-libx265     \
            --enable-openssl     \
            --enable-libdav1d    \
            --enable-libsvtav1   \
            --ignore-tests=enhanced-flv-av1,enhanced-flv-multitrack \
            --docdir=/usr/share/doc/ffmpeg-9.0.1 &&

make &&

gcc tools/qt-faststart.c -o tools/qt-faststart
make install &&

install -v -m755    tools/qt-faststart /usr/bin &&
install -v -m755 -d           /usr/share/doc/ffmpeg-9.0.1 &&
install -v -m644    doc/*.txt /usr/share/doc/ffmpeg-9.0.1
install -v -m755 -d /usr/share/doc/ffmpeg-9.0.1/api                     &&
cp -vr doc/doxy/html/* /usr/share/doc/ffmpeg-9.0.1/api                  &&
find /usr/share/doc/ffmpeg-9.0.1/api -type f -exec chmod -c 0644 \{} \; &&
find /usr/share/doc/ffmpeg-9.0.1/api -type d -exec chmod -c 0755 \{} \;
make fate-rsync SAMPLES=fate-suite/
rsync -vrltLW  --delete --timeout=60 --contimeout=60 \
      rsync://fate-suite.ffmpeg.org/fate-suite/ fate-suite/
make fate THREADS=N SAMPLES=fate-suite/ | tee ../fate.log &&
grep ^TEST ../fate.log | wc -l

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

