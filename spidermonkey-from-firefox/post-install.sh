#!/bin/bash
# AryaLinux post-install
# spidermonkey-from-firefox — SpiderMonkey from firefox-140.14.0
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed '$i#define XP_UNIX' -i /usr/include/mozjs-140/js-config.h
