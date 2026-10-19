#!/bin/bash
# AryaLinux post-install
# gsettings-desktop-schemas — gsettings-desktop-schemas-50.1
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

glib-compile-schemas /usr/share/glib-2.0/schemas
