#!/bin/bash
# AryaLinux post-install
# libxext — libXext-1.3.7
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

ln -sv $XORG_PREFIX/lib/X11 /usr/lib/X11 &&
ln -sv $XORG_PREFIX/include/X11 /usr/include/X11
