#!/bin/bash
# AryaLinux post-install
# p11-kit — p11-kit-0.26.5
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so

