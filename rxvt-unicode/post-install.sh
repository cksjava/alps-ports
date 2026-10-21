#!/bin/bash
# AryaLinux post-install
# rxvt-unicode — rxvt-unicode-9.31
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat >> /etc/X11/app-defaults/URxvt << "EOF"
! Use the specified colour as the windows background colour [default white]
URxvt*background: black

! Use the specified colour as the windows foreground colour [default black]
URxvt*foreground: yellow

! Select the fonts to be used. This is a comma separated list of font names
URxvt*font: xft:Monospace:pixelsize=18

! Comma-separated list(s) of perl extension scripts (default: "default")
URxvt*perl-ext: matcher

! Specifies the program to be started with a URL argument. Used by
URxvt*url-launcher: firefox

! When clicked with the mouse button specified in the "matcher.button" resource
! (default 2, or middle), the program specified in the "matcher.launcher"
! resource (default, the "url-launcher" resource, "sensible-browser") will be
! started with the matched text as first argument.
! Below, default modified to mouse left button.
URxvt*matcher.button:     1
EOF
xrdb -query
xrdb -merge ~/.Xresources
cat > /usr/share/applications/urxvt.desktop << "EOF" &&
[Desktop Entry]
Encoding=UTF-8
Name=Rxvt-Unicode Terminal
Comment=Use the command line
GenericName=Terminal
Exec=urxvt
Terminal=false
Type=Application
Icon=utilities-terminal
Categories=GTK;Utility;TerminalEmulator;
#StartupNotify=true
Keywords=console;command line;execute;
EOF

update-desktop-database -q

