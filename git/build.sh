#!/bin/bash
# AryaLinux package build
# git — Git-2.55.0
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

echo "=== Git-2.55.0 ==="
cd "$ARYA_SOURCES"
tarball="git-2.55.0.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

./configure --prefix=/usr                   \
            --with-gitconfig=/etc/gitconfig \
            --with-python=python3           \
            --with-libpcre2                 &&
make
make html
make man
make perllibdir=/usr/lib/perl5/5.44/site_perl install
make install-man
make htmldir=/usr/share/doc/git-2.55.0 install-html
tar -xf ../git-manpages-2.55.0.tar.xz \
    -C /usr/share/man --no-same-owner --no-overwrite-dir
mkdir -vp   /usr/share/doc/git-2.55.0 &&
tar   -xf   ../git-htmldocs-2.55.0.tar.xz \
      -C    /usr/share/doc/git-2.55.0 --no-same-owner --no-overwrite-dir &&

find        /usr/share/doc/git-2.55.0 -type d -exec chmod 755 {} \; &&
find        /usr/share/doc/git-2.55.0 -type f -exec chmod 644 {} \;
mkdir -vp /usr/share/doc/git-2.55.0/man-pages/{html,text}         &&
mv        /usr/share/doc/git-2.55.0/{git*.adoc,man-pages/text}    &&
mv        /usr/share/doc/git-2.55.0/{git*.,index.,man-pages/}html &&

mkdir -vp /usr/share/doc/git-2.55.0/technical/{html,text}         &&
mv        /usr/share/doc/git-2.55.0/technical/{*.adoc,text}       &&
mv        /usr/share/doc/git-2.55.0/technical/{*.,}html           &&

mkdir -vp /usr/share/doc/git-2.55.0/howto/{html,text}             &&
mv        /usr/share/doc/git-2.55.0/howto/{*.adoc,text}           &&
mv        /usr/share/doc/git-2.55.0/howto/{*.,}html               &&

sed -i '/^<a href=/s|howto/|&html/|' /usr/share/doc/git-2.55.0/howto-index.html &&
sed -i '/^\* link:/s|howto/|&html/|' /usr/share/doc/git-2.55.0/howto-index.adoc

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

