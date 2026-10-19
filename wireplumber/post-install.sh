#!/bin/bash
# AryaLinux post-install
# wireplumber — Wireplumber-0.5.15
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

rm -vf /etc/xdg/autostart/pulseaudio.desktop         &&
rm -vf /etc/xdg/Xwayland-session.d/00-pulseaudio-x11 &&
sed -e '$a autospawn = no' -i /etc/pulse/client.conf
systemctl enable --global pipewire.socket       &&
systemctl enable --global pipewire-pulse.socket &&
systemctl enable --global wireplumber
