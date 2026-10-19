#!/bin/bash
# AryaLinux post-install
# acpid — acpid-2.0.34
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat > /etc/acpi/events/lid << "EOF"
event=button/lid
action=/etc/acpi/lid.sh
EOF

cat > /etc/acpi/lid.sh << "EOF"
#!/bin/sh
/bin/grep -q open /proc/acpi/button/lid/LID/state && exit 0
/usr/bin/systemctl suspend
EOF
chmod +x /etc/acpi/lid.sh

mkdir -pv /etc/systemd/logind.conf.d
echo HandleLidSwitch=ignore > /etc/systemd/logind.conf.d/acpi.conf
