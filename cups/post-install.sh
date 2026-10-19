#!/bin/bash
# AryaLinux post-install
# cups — Cups-2.4.19
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in
sed -i '/& ipp->prev)/s/prev/& \&\& ipp->prev->next == *attr/' cups/ipp.c
echo "ServerName /run/cups/cups.sock" > /etc/cups/client.conf
gtk-update-icon-cache -qtf /usr/share/icons/hicolor
cat > /etc/pam.d/cups << "EOF"
# Begin /etc/pam.d/cups

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/cups
EOF
systemctl enable cups
