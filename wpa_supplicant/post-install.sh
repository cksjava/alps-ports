#!/bin/bash
# AryaLinux post-install
# wpa_supplicant — wpa_supplicant-2.12
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

install -v -dm755 /etc/wpa_supplicant &&
wpa_passphrase SSID | sed '/^\t#/d' > /etc/wpa_supplicant/wpa_supplicant-wifi0.conf
systemctl start wpa_supplicant@wlan0
systemctl enable wpa_supplicant@wlan0

