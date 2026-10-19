#!/bin/bash
# AryaLinux post-install
# xcb-proto — xcb-proto-1.17.0
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

rm -f $XORG_PREFIX/lib/pkgconfig/xcb-proto.pc
