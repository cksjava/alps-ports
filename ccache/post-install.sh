#!/bin/bash
# AryaLinux post-install
# ccache — ccache-4.14.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

install -vdm755 /usr/lib/ccache
for compiler in cc c++ gcc g++; do
    ln -sfn ../../bin/ccache "/usr/lib/ccache/${compiler}"
done
