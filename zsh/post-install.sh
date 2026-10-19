#!/bin/bash
# AryaLinux post-install
# zsh — zsh-5.9.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -e 's|/etc/z|/etc/zsh/z|g' \
    -i Doc/*.*
cat >> /etc/shells << "EOF"
/bin/zsh
EOF
