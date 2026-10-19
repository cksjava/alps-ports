#!/bin/bash
# AryaLinux post-install
# xdg-desktop-portal-wlr — xdg-desktop-portal-wlr-0.8.3
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat > /usr/share/xdg-desktop-portal/wlr-portals.conf << "EOF"
[preferred]
default=wlr
EOF
