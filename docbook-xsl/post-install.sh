#!/bin/bash
# AryaLinux post-install
# docbook-xsl — docbook-xsl-nons-1.79.2
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

(set -e

 install -v -d -m755 /etc/xml
 [ -e /etc/xml/catalog ] || xmlcatalog --noout --create /etc/xml/catalog

 for uri in http{,s}://cdn.docbook.org/release/xsl-nons/{1.79.2,current} \
            http://docbook.sourceforge.net/release/xsl/current; do
   for rewrite in System URI; do
     xmlcatalog --noout --add "rewrite$rewrite"             \
       "$uri"                                               \
       "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
       /etc/xml/catalog
   done
 done)

