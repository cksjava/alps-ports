#!/bin/bash
# AryaLinux post-install
# openbox — openbox-3.6.1
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

rm -v /usr/share/xsessions/openbox-{gnome,kde}.desktop
cp -rf /etc/xdg/openbox ~/.config
ls -d /usr/share/themes/*/openbox-3 | sed 's#.*es/##;s#/o.*##'
