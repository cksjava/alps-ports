#!/bin/bash
# AryaLinux post-install
# aspell — Aspell-0.60.8.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

tar xf ../aspell6-en-2020.12.07-0.tar.bz2 &&
cd aspell6-en-2020.12.07-0                &&

./configure &&
make
make install
