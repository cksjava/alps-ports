#!/bin/bash
# AryaLinux post-install
# postfix — Postfix-3.11.6
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -i 's/.\x08//g' README_FILES/*
CCARGS="-DNO_NIS -DNO_DB"
AUXLIBS=""
cat >> /etc/aliases << "EOF"
# Begin /etc/aliases

MAILER-DAEMON:    postmaster
postmaster:       root

root:             <LOGIN>
# End /etc/aliases
EOF
echo 'default_database_type = lmdb'       >> /etc/postfix/main.cf &&
echo 'alias_database = lmdb:/etc/aliases' >> /etc/postfix/main.cf &&
echo 'alias_maps = lmdb:/etc/aliases'     >> /etc/postfix/main.cf
echo 'smtpd_forbid_bare_newline = normalize' >> /etc/postfix/main.cf &&
echo 'smtpd_forbid_bare_newline_exclusions = $mynetworks' >> /etc/postfix/main.cf
/usr/sbin/postfix -c /etc/postfix set-permissions
/usr/sbin/postfix upgrade-configuration
/usr/sbin/postfix check &&
/usr/sbin/postfix start
