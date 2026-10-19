#!/bin/bash
# AryaLinux post-install
# lvm2 — LVM2-2.03.42
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -e '/locking_dir =/{s/#//;s/var/run/}' \
    -i /etc/lvm/lvm.conf
