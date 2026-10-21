#!/bin/bash
# AryaLinux package build
# postfix — Postfix-3.11.6
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

echo "=== Postfix-3.11.6 ==="
cd "$ARYA_SOURCES"
tarball="postfix-3.11.6.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

groupadd -g 32 postfix &&
groupadd -g 33 postdrop &&
useradd -c "Postfix Daemon User" -d /var/spool/postfix -g postfix \
        -s /bin/false -u 32 postfix &&
chown -v postfix:postfix /var/mail
if [ -r /usr/lib/libsasl2.so ]; then
  CCARGS="$CCARGS -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl"
  AUXLIBS="$AUXLIBS -lsasl2"
fi
if [ -r /usr/lib/liblmdb.so ]; then
  CCARGS="$CCARGS -DHAS_LMDB"
  AUXLIBS_LMDB="-llmdb"
fi
if [ -r /usr/lib/libldap.so -a -r /usr/lib/liblber.so ]; then
  CCARGS="$CCARGS -DHAS_LDAP"
  AUXLIBS="$AUXLIBS -lldap -llber"
fi
if [ -r /usr/lib/libsqlite3.so ]; then
  CCARGS="$CCARGS -DHAS_SQLITE"
  AUXLIBS="$AUXLIBS -lsqlite3 -lpthread"
fi
if [ -r /usr/lib/libmysqlclient.so ]; then
  CCARGS="$CCARGS -DHAS_MYSQL -I/usr/include/mysql"
  AUXLIBS="$AUXLIBS -lmysqlclient -lz -lm"
fi
if [ -r /usr/lib/libpq.so ]; then
  CCARGS="$CCARGS -DHAS_PGSQL -I/usr/include/postgresql"
  AUXLIBS="$AUXLIBS -lpq -lz -lm"
fi
if [ -r /usr/lib/libssl.so -a -r /usr/lib/libcrypto.so ]; then
  CCARGS="$CCARGS -DUSE_TLS -I/usr/include/openssl/"
  AUXLIBS="$AUXLIBS -lssl -lcrypto"
fi
make makefiles                    \
     CCARGS="$CCARGS"             \
     AUXLIBS="$AUXLIBS"           \
     AUXLIBS_LMDB="$AUXLIBS_LMDB" \
     default_database_type=lmdb   \
     default_cache_db_type=lmdb   &&
make
sh postfix-install -non-interactive  \
   daemon_directory=/usr/lib/postfix \
   manpage_directory=/usr/share/man  \
   html_directory=/usr/share/doc/postfix-3.11.6/html \
   readme_directory=/usr/share/doc/postfix-3.11.6/readme

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

