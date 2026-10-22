#!/bin/bash
# AryaLinux package build
# apache — Apache-2.4.68
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

echo "=== Apache-2.4.68 ==="
cd "$ARYA_SOURCES"
tarball="httpd-2.4.68.tar.bz2"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

groupadd -g 25 apache &&
useradd -c "Apache Server" -d /srv/www -g apache \
        -s /bin/false -u 25 apache
patch -Np1 -i ../httpd-2.4.68-openssl4_fixes-1.patch
patch -Np1 -i ../httpd-blfs_layout-1.patch             &&

sed '/dir.*CFG_PREFIX/s@^@#@' -i support/apxs.in       &&

sed -e '/HTTPD_ROOT/s:${ap_prefix}:/etc/httpd:'       \
    -e '/SERVER_CONFIG_FILE/s:${rel_sysconfdir}/::'   \
    -e '/AP_TYPES_CONFIG_FILE/s:${rel_sysconfdir}/::' \
    -i configure  &&

./configure --enable-authnz-fcgi                    \
            --enable-layout=BLFS                    \
            --enable-mods-shared="all cgi"          \
            --enable-mpms-shared=all                \
            --enable-suexec=shared                  \
            --with-apr=/usr/bin/apr-1-config        \
            --with-apr-util=/usr/bin/apu-1-config   \
            --with-suexec-bin=/usr/lib/httpd/suexec \
            --with-suexec-caller=apache             \
            --with-suexec-docroot=/srv/www          \
            --with-suexec-uidmin=100                \
            --with-suexec-userdir=public_html       \
            --with-suexec-logfile=/var/log/httpd/suexec.log &&
make
make install  &&

mv -v /usr/sbin/suexec /usr/lib/httpd/suexec &&
chgrp apache           /usr/lib/httpd/suexec &&
chmod 4754             /usr/lib/httpd/suexec &&

chown -v -R apache:apache /srv/www

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

