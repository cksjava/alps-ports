#!/bin/bash
# AryaLinux post-install
# inkscape — Inkscape-1.4.4
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
update-desktop-database -q
