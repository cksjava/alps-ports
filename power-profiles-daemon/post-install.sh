#!/bin/bash
# AryaLinux post-install
# power-profiles-daemon — Power-profiles-daemon-0.30
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

systemctl enable power-profiles-daemon
powerprofilesctl
powerprofilesctl set performance
gov=performance
for CPUFREQ in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor; do
  echo -n ${gov} > ${CPUFREQ}
done

