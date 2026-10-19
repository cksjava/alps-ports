#!/bin/bash
# AryaLinux post-install
# tcsh — Tcsh-6.24.16
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat >> /etc/shells << "EOF"
/bin/tcsh
/bin/csh
EOF
cat > ~/.cshrc << "EOF"
# Original at:
# https://www.cs.umd.edu/~srhuang/teaching/code_snippets/prompt_color.tcsh.html

# Modified by the BLFS Development Team.

# Add these lines to your ~/.cshrc (or to /etc/csh.cshrc).

# Colors!
set     red="%{\033[1;31m%}"
set   green="%{\033[0;32m%}"
set  yellow="%{\033[1;33m%}"
set    blue="%{\033[1;34m%}"
set magenta="%{\033[1;35m%}"
set    cyan="%{\033[1;36m%}"
set   white="%{\033[0;37m%}"
set     end="%{\033[0m%}" # This is needed at the end...

# Setting the actual prompt.  Two separate versions for you to try, pick
# whichever one you like better, and change the colors as you want.
# Just don't mess with the ${end} guy in either line...  Comment out or
# delete the prompt you don't use.

set prompt="${green}%n${blue}@%m ${white}%~ ${green}%%${end} "
set prompt="[${green}%n${blue}@%m ${white}%~ ]${end} "

# This was not in the original URL above
# Provides coloured ls
alias ls ls --color=always

# Clean up after ourselves...
unset red green yellow blue magenta cyan yellow white end
EOF
