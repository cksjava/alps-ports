#!/bin/bash
# AryaLinux post-install
# openldap — OpenLDAP-2.7.0
# Run after the package is installed. The build directory is already gone.
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
if [[ ! -d "$ARYA_SOURCES" && -n "${LFS:-}" && -d "$LFS/sources" ]]; then
    ARYA_SOURCES="$LFS/sources"
fi

_arya_install_systemd_unit() {
    local tarball="blfs-systemd-units-20251204.tar.xz"
    local url="https://www.linuxfromscratch.org/blfs/downloads/13.1-systemd/blfs-systemd-units-20251204.tar.xz"
    local srcdir caller=$PWD
    cd "$ARYA_SOURCES"
    if [[ ! -f "$tarball" ]]; then
        wget -O "${tarball}.partial" "$url"
        mv "${tarball}.partial" "$tarball"
    fi
    srcdir=$(get_srcdir "$tarball")
    if [[ ! -d "$srcdir" ]]; then
        extract_archive "$tarball"
    fi
    (
        cd "$srcdir"
        make "$@"
    )
    cd "$caller"
}

_arya_install_systemd_unit slapd
systemctl start slapd
ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts

