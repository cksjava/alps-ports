#!/bin/bash
# AryaLinux post-install
# wireshark — Wireshark-4.6.8
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

chown -v root:wireshark /usr/bin/tshark &&
chmod -v 6550 /usr/bin/tshark
