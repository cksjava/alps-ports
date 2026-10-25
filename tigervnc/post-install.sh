#!/bin/bash
# AryaLinux post-install
# tigervnc — Tigervnc-1.16.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

_arya_in_chroot() {
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        systemd-detect-virt --chroot >/dev/null 2>&1
        return
    fi
    [[ -r /proc/1/root/. ]] || return 1
    [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]]
}

install -vdm755 /etc/X11/tigervnc &&
install -v -m755 ../Xsession /etc/X11/tigervnc
ME=$(echo :1=$(whoami))
bash -c "echo $ME >> /etc/tigervnc/vncserver.users"
install -vdm 755 ~/.config/tigervnc &&
cat > ~/.config/tigervnc/config << EOF
# Begin ~/.config/tigervnc/config
# The session must match one listed in /usr/share/xsessions.
# Ensure that there are no spaces at the end of the lines.

session=lxqt
geometry=1024x768

# End ~/.config/tigervnc/config
EOF
if _arya_in_chroot; then
    echo "Skipping commands that need a running service; this is a chroot."
else
    systemctl start vncserver@:1
fi
systemctl enable vncserver@:1

