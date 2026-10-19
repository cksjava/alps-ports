#!/bin/bash
# AryaLinux post-install
# transmission — Transmission-4.1.3
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

rsvg-convert                                                   \
   /usr/share/icons/hicolor/scalable/apps/transmission-gtk.svg \
   -o /usr/share/pixmaps/transmission.png
