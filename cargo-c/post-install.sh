#!/bin/bash
# AryaLinux post-install
# cargo-c — cargo-c-0.10.24
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG
