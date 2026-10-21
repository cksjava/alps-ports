#!/bin/bash
# AryaLinux post-install
# samba — Samba-4.24.6
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

install -dvm 755 /usr/lib/cups/backend &&
ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb
systemctl enable smb.service
systemctl enable winbind.service

