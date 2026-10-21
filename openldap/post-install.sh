#!/bin/bash
# AryaLinux post-install
# openldap — OpenLDAP-2.7.0
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

make install-slapd
systemctl start slapd
ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts

