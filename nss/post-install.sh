#!/bin/bash
# AryaLinux post-install
# nss — NSS-3.126
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

