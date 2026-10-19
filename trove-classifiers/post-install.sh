#!/bin/bash
# AryaLinux post-install
# trove-classifiers — Trove-Classifiers-2026.6.1.19
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -i '/calver/s/^/#/;$iversion="2026.6.1.19"' setup.py
