#!/bin/bash
# AryaLinux post-install
# dovecot — Dovecot-2.4.4
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

mv -v /etc/dovecot/dovecot.conf{,.orig} &&
chmod -v 1777 /var/mail &&
cat > /etc/dovecot/dovecot.conf << "EOF"

# The dovecot configuration requires a minimum version to be set. The server
# will refuse to start if the version set here is older than the version of
# Dovecot installed. This option allows the Dovecot server to set reasonable
# default values based on what version is set here.
dovecot_config_version = 2.4.4

# This option sets the minimum version that is able to read data files from
# the Dovecot server. This is primarily for a cluster which may have several
# different versions of Dovecot installed, but is required for the server to
# run.
dovecot_storage_version = 2.4.4

protocols = imap
ssl = no
# The next line is only needed if you have no IPv6 network interfaces
listen = *
mail_inbox_path = /var/mail/%{user}
mail_driver = mbox
mail_path = ~/Mail
userdb users {
  driver = passwd
}
passdb passwords {
  driver = pam
}
EOF
cat > /etc/pam.d/dovecot << "EOF"
# Begin /etc/pam.d/dovecot

auth     include system-auth
account  include system-account
password include system-password

# End /etc/pam.d/dovecot
EOF
systemctl enable dovecot

