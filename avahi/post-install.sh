#!/bin/bash
# AryaLinux post-install
# avahi — Avahi-0.9-rc5
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

mkdir -pv /etc/systemd/resolved.conf.d &&
cat > /etc/systemd/resolved.conf.d/no-mdns.conf << EOF &&
[Resolve]
MulticastDNS=no
EOF
systemctl enable avahi-daemon
systemctl enable avahi-dnsconfd

