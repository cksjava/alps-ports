#!/bin/bash
# AryaLinux post-install
# libpaper — libpaper-2.2.8
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

mkdir -pv ~/.config &&
echo "a4" > ~/.config/papersize
echo "PAPERSIZE=a4" > /etc/profile.d/libpaper.sh
