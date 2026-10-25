#!/bin/bash
# AryaLinux post-install
# ntp — ntp-4.2.8p18
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

cat > /etc/ntp.conf << "EOF"
# Asia
server 0.asia.pool.ntp.org

# Australia
server 0.oceania.pool.ntp.org

# Europe
server 0.europe.pool.ntp.org

# North America
server 0.north-america.pool.ntp.org

# South America
server 2.south-america.pool.ntp.org

driftfile /var/lib/ntp/ntp.drift
pidfile   /run/ntpd.pid
EOF
_arya_install_systemd_unit ntpd
systemctl disable systemd-timesyncd.service

