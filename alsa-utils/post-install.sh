#!/bin/bash
# AryaLinux post-install
# alsa-utils — alsa-utils-1.2.16
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

alsactl init
alsactl -L store
cat > /etc/asound.conf << "EOF"
# Begin /etc/asound.conf

defaults.pcm.card 1
defaults.ctl.card 1

# End /etc/asound.conf
EOF
