#!/bin/bash
# AryaLinux post-install
# postgresql — PostgreSQL-18.6
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

# shellcheck disable=SC1091
source /var/lib/alps/env.sh
# shellcheck disable=SC1091
source /var/lib/alps/alpslib.sh

: "${ARYA_SOURCES:=/sources}"
if [[ ! -d "$ARYA_SOURCES" && -n "${LFS:-}" && -d "$LFS/sources" ]]; then
    ARYA_SOURCES="$LFS/sources"
fi

_arya_install_systemd_unit() {
    local tarball="blfs-systemd-units-20251204.tar.xz"
    local url="https://www.linuxfromscratch.org/blfs/downloads/13.1-systemd/blfs-systemd-units-20251204.tar.xz"
    local srcdir caller=$PWD
    cd "$ARYA_SOURCES"
    if [[ ! -f "$tarball" ]]; then
        wget -O "${tarball}.partial" "$url"
        mv "${tarball}.partial" "$tarball"
    fi
    srcdir=$(get_srcdir "$tarball")
    if [[ ! -d "$srcdir" ]]; then
        extract_archive "$tarball"
    fi
    (
        cd "$srcdir"
        make "$@"
    )
    cd "$caller"
}

_arya_install_systemd_unit install-postgresql
if _arya_in_chroot; then
    echo "Skipping commands that need a running service; this is a chroot."
else
    systemctl start postgresql
fi
if _arya_in_chroot; then
    echo "Skipping commands that need a running service; this is a chroot."
else
    su - postgres -c '/usr/bin/createdb test' &&
    echo "create table t1 ( name varchar(20), state_province varchar(20) );" \
        | (su - postgres -c '/usr/bin/psql test ') &&
    echo "insert into t1 values ('Billy', 'NewYork');" \
        | (su - postgres -c '/usr/bin/psql test ') &&
    echo "insert into t1 values ('Evanidus', 'Quebec');" \
        | (su - postgres -c '/usr/bin/psql test ') &&
    echo "insert into t1 values ('Jesse', 'Ontario');" \
        | (su - postgres -c '/usr/bin/psql test ') &&
    echo "select * from t1;" | (su - postgres -c '/usr/bin/psql test')
fi
if _arya_in_chroot; then
    echo "Skipping commands that need a running service; this is a chroot."
else
    systemctl stop postgresql
fi

