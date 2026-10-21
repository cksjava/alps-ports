#!/bin/bash
# AryaLinux post-install
# python3 — Python-3.14.7
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

ln -svfn python-3.14.7 /usr/share/doc/python-3
export PYTHONDOCS=/usr/share/doc/python-3/html

