#!/bin/bash
# AryaLinux post-install
# at — at-3.2.5
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat > /etc/pam.d/atd << "EOF"
# Begin /etc/pam.d/atd

auth     required pam_unix.so
account  required pam_unix.so
password required pam_unix.so
session  required pam_unix.so

# End /etc/pam.d/atd
EOF
systemctl enable atd

