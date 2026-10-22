#!/bin/bash
# AryaLinux package build
# exim — Exim-4.100
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

echo "=== Exim-4.100 ==="
cd "$ARYA_SOURCES"
tarball="exim-4.100.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

groupadd -g 31 exim &&
useradd -d /dev/null -c "Exim Daemon" -g exim -s /bin/false -u 31 exim
sed -e 's|^BIN_DIR.*$|BIN_DIRECTORY=/usr/sbin|'    \
    -e 's|^CONF.*$|CONFIGURE_FILE=/etc/exim.conf|' \
    -e 's|^EXIM_USER.*$|EXIM_USER=exim|'           \
    -e '/# USE_OPENSSL/s|^#||'                     \
    src/EDITME > Local/Makefile &&

printf "USE_GDBM = yes\nDBMLIB = -lgdbm\n" >> Local/Makefile
make
make install                                    &&
install -v -m644 doc/exim.8 /usr/share/man/man8 &&

install -vdm 755    /usr/share/doc/exim-4.100 &&
cp      -Rv doc/*   /usr/share/doc/exim-4.100 &&

ln -sfv exim /usr/sbin/sendmail                 &&
install -v -d -m750 -o exim -g exim /var/spool/exim

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

