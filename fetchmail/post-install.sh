#!/bin/bash
# AryaLinux post-install
# fetchmail — Fetchmail-6.6.7
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat > ~/.fetchmailrc << "EOF"

# The logfile needs to exist when fetchmail is invoked, otherwise it will
# dump the details to the screen. As with all logs, you will need to rotate
# or clear it from time to time.
set logfile fetchmail.log
set no bouncemail
# You probably want to set your local username as the postmaster
set postmaster <username>

poll SERVERNAME :
    user <isp_username> pass <password>;
    mda "/usr/bin/procmail -f %F -d %T";
EOF

touch ~/fetchmail.log       &&
chmod -v 0600 ~/.fetchmailrc
