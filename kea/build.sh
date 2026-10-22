#!/bin/bash
# AryaLinux package build
# kea — Kea 3.0.2 DHCP Server
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

echo "=== Kea 3.0.2 DHCP Server ==="
cd "$ARYA_SOURCES"
tarball="kea-3.0.2.tar.xz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(get_srcdir "$tarball")
rm -rf "$srcdir"
extract_archive "$tarball"
cd "$srcdir"

sed -e "/asio_wrapper/a#include <boost/asio/deadline_timer.hpp>" \
    -i src/lib/asiolink/interval_timer.cc                        \
       src/lib/asiodns/io_fetch.cc                               \
       src/lib/asiodns/tests/io_fetch_unittest.cc                &&
sed -e "/lexical_cast.hpp/a #include <boost/static_assert.hpp>"  \
    -i src/lib/log/logger_level_impl.cc                          \
       src/lib/dns/rdataclass.cc
sed -e 's/^[ ]*\(::X509_NAME\)/const \1/' \
    -i src/lib/asiolink/openssl_tls.h
mkdir build &&
cd    build &&

meson setup ..             \
      --prefix=/usr        \
      --sysconfdir=/etc    \
      --localstatedir=/var \
      --buildtype=release  \
      -D crypto=openssl    \
      -D runstatedir=/run  &&

ninja
ninja install
sed -e "s:\${prefix}/::" -i /usr/sbin/keactrl             &&
sed -e "s:\${prefix}//etc:/etc:" -i /etc/kea/keactrl.conf
install -dm0750 /var/lib/kea
install -dm0750 /var/log/kea

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

