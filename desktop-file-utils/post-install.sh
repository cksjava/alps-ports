#!/bin/bash
# AryaLinux post-install
# desktop-file-utils — desktop-file-utils-0.28
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

install -vdm755 /usr/share/applications &&
update-desktop-database /usr/share/applications
