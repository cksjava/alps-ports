#!/bin/bash
# AryaLinux package build
# mariadb — MariaDB-12.3.3
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

echo "=== MariaDB-12.3.3 ==="
cd "$ARYA_SOURCES"
tarball="mariadb-12.3.3.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

patch -Np1 -i ../mariadb-12.3.3-openssl4_fixes-1.patch
mkdir build &&
cd    build &&

cmake -D CMAKE_BUILD_TYPE=Release                       \
      -D CMAKE_INSTALL_PREFIX=/usr                      \
      -D GRN_LOG_PATH=/var/log/groonga.log              \
      -D INSTALL_DOCDIR=share/doc/mariadb-12.3.3        \
      -D INSTALL_DOCREADMEDIR=share/doc/mariadb-12.3.3  \
      -D INSTALL_MANDIR=share/man                       \
      -D INSTALL_MYSQLSHAREDIR=share/mariadb            \
      -D INSTALL_MYSQLTESTDIR=share/mariadb/test        \
      -D INSTALL_PAMDIR=lib/security                    \
      -D INSTALL_PAMDATADIR=/etc/security               \
      -D INSTALL_PLUGINDIR=lib/mariadb/plugin           \
      -D INSTALL_SBINDIR=sbin                           \
      -D INSTALL_SCRIPTDIR=bin                          \
      -D INSTALL_SQLBENCHDIR=share/mariadb/bench        \
      -D INSTALL_SUPPORTFILESDIR=share/mariadb          \
      -D MYSQL_DATADIR=/srv/mariadb                     \
      -D MYSQL_UNIX_ADDR=/run/mariadb/mariadb.sock      \
      -D WITH_EXTRA_CHARSETS=complex                    \
      -D WITH_EMBEDDED_SERVER=ON                        \
      -D SKIP_TESTS=ON                                  \
      -D TOKUDB_OK=0                                    \
      -W no-author                                      \
      .. &&
make
make install
make install-mariadb

cd "$ARYA_SOURCES"
rm -rf "$srcdir"
