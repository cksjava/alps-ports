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

_arya_in_chroot() {
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        systemd-detect-virt --chroot >/dev/null 2>&1
        return
    fi
    [[ -r /proc/1/root/. ]] || return 1
    [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]
}

install -v -dm755 /etc/wpa_supplicant &&
wpa_passphrase SSID | sed '/^\t#/d' > /etc/wpa_supplicant/wpa_supplicant-wifi0.conf
if _arya_in_chroot; then
    echo "Skipping commands that need a running service; this is a chroot."
else
    systemctl start wpa_supplicant@wlan0
fi
systemctl enable wpa_supplicant@wlan0

