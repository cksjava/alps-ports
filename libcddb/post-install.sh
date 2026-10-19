#!/bin/bash
# AryaLinux post-install
# libcddb — libcddb-1.3.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -e '/DEFAULT_SERVER/s/freedb.org/gnudb.gnudb.org/' \
    -e '/DEFAULT_PORT/s/888/&0/'                       \
    -i include/cddb/cddb_ni.h                          &&
sed '/^Genre:/s/Trip-Hop/Electronic/' -i tests/testdata/920ef00b.txt &&
sed '/DISCID/i# Revision: 42'         -i tests/testcache/misc/12340000
sed -i 's/size_t l;/socklen_t l;/' lib/cddb_net.c
