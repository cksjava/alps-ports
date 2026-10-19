#!/bin/bash
# AryaLinux post-install
# lsb-tools — LSB-Tools-0.12
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

rm /usr/sbin/lsbinstall
rm /usr/sbin/{install,remove}_initd
