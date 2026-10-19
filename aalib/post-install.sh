#!/bin/bash
# AryaLinux post-install
# aalib — AAlib-1.4rc5
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

sed -i -e '/AM_PATH_AALIB,/s/AM_PATH_AALIB/[&]/' aalib.m4
sed -e 's/8x13bold/-*-luxi mono-bold-r-normal--13-120-*-*-m-*-*-*/' \
    -i src/aax.c
sed 's/stdscr->_max\([xy]\) + 1/getmax\1(stdscr)/' \
    -i src/aacurses.c
sed -i '1i#include <stdlib.h>'                            \
    src/aa{fire,info,lib,linuxkbd,savefont,test,regist}.c &&
sed -i '1i#include <string.h>'                            \
    src/aa{kbdreg,moureg,test,regist}.c                   &&
sed -i '/X11_KBDDRIVER/a#include <X11/Xutil.h>'           \
    src/aaxkbd.c                                          &&
sed -i '/rawmode_init/,/^}/s/return;/return 0;/'          \
    src/aalinuxkbd.c                                      &&
autoconf
