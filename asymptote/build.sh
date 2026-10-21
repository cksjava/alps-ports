#!/bin/bash
# AryaLinux package build
# asymptote — asymptote-3.14
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

echo "=== asymptote-3.14 ==="
cd "$ARYA_SOURCES"
tarball="asymptote-3.14.src.tgz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

sed -i "/SHIMLIB.*asydir/d" Makefile.in
export TEXARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/$/-linux/') &&

./configure --prefix=$TEXLIVE_PREFIX                          \
            --bindir=$TEXLIVE_PREFIX/bin/$TEXARCH             \
            --datarootdir=$TEXLIVE_PREFIX/texmf-dist          \
            --infodir=$TEXLIVE_PREFIX/texmf-dist/doc/info     \
            --libdir=$TEXLIVE_PREFIX/texmf-dist               \
            --mandir=$TEXLIVE_PREFIX/texmf-dist/doc/man       \
            --disable-lsp                                     \
            --disable-vulkan                                  \
            --disable-gl                                      \
            --with-latex=$TEXLIVE_PREFIX/texmf-dist/tex/latex \
            --with-context=$TEXLIVE_PREFIX/texmf-dist/tex/context/third &&

make
make install

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

