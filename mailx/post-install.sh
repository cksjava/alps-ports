#!/bin/bash
# AryaLinux post-install
# mailx — mailx-12.5
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

echo "set PAGER=<more|less>" >> /etc/nail.rc
echo "set PAGER=<more|less>" >> ~/.mailrc
echo "set EDITOR=<vim|nano|...>" >> /etc/nail.rc
echo "set MAILDIR=Maildir" >> /etc/nail.rc
