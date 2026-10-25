#!/bin/bash
# AryaLinux post-install
# wayfire — wayfire-0.11.0
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

mkdir -pv /etc/skel/.config
cp -v /usr/share/wayfire/wayfire.ini /etc/skel/.config/wayfire.ini

