#!/bin/bash
# AryaLinux package build
# zsh — zsh-5.9.2
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

echo "=== zsh-5.9.2 ==="
cd "$ARYA_SOURCES"
tarball="zsh-5.9.2.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

sed -e 's|/etc/z|/etc/zsh/z|g' \
    -i Doc/*.*
./configure --prefix=/usr            \
            --sysconfdir=/etc/zsh    \
            --enable-etcdir=/etc/zsh \
            --enable-cap             \
            --enable-gdbm            \
            --enable-pcre            &&
make                                 &&

makeinfo  Doc/zsh.texi --html      -o Doc/html &&
makeinfo  Doc/zsh.texi --plaintext -o zsh.txt  &&
makeinfo  Doc/zsh.texi --html --no-split --no-headers -o zsh.html
texi2pdf  Doc/zsh.texi -o Doc/zsh.pdf
make install                                                    &&
make infodir=/usr/share/info install.info                       &&
make htmldir=/usr/share/doc/zsh-5.9.2/html install.html         &&
install -v -m644 zsh.{html,txt} Etc/FAQ /usr/share/doc/zsh-5.9.2
install -v -m644 Doc/zsh.pdf /usr/share/doc/zsh-5.9.2

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

