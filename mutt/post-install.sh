#!/bin/bash
# AryaLinux post-install
# mutt — Mutt-2.4.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat /usr/share/doc/mutt-2.4.2/samples/gpg.rc >> ~/.muttrc

