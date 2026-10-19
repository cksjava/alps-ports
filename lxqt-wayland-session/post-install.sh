#!/bin/bash
# AryaLinux post-install
# lxqt-wayland-session — lxqt-wayland-session-0.4.1
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

mkdir -pv ~/.config/lxqt &&
cp -v /usr/share/lxqt/session.conf ~/.config/lxqt &&
sed -i '/\[Environment\]/a compositor=wayfire' \
       ~/.config/lxqt/session.conf
