#!/bin/bash
# AryaLinux post-install
# openjdk — OpenJDK-21.0.12.1
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

ln -sfv /etc/pki/tls/java/cacerts /opt/jdk/lib/security/cacerts
cd /opt/jdk
bin/keytool -list -cacerts

