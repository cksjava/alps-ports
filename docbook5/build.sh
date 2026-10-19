#!/bin/bash
# AryaLinux package build
# docbook5 — docbook-xml-5.0
# Instructions follow the book. Test-suite commands are omitted.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

: "${ARYA_SOURCES:=/sources}"
: "${ARYA_ROOT:=/aryalinux-builder}"
if [[ ! -d "$ARYA_SOURCES" && -n "${LFS:-}" && -d "$LFS/sources" ]]; then
    ARYA_SOURCES="$LFS/sources"
fi

_arya_here=$(cd "$(dirname "$0")" && pwd)
if [[ -r "$_arya_here/../../lib/idempotent.sh" ]]; then
    # shellcheck disable=SC1091
    source "$_arya_here/../../lib/idempotent.sh"
fi

echo "=== docbook-xml-5.0 ==="
cd "$ARYA_SOURCES"
tarball="docbook-5.0.zip"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

install -vdm755 /usr/share/xml/docbook/xml-5.0 &&
cp -rv catalog.xml dtd rng sch xsd /usr/share/xml/docbook/xml-5.0
if [ ! -e /etc/xml/catalog ]; then
    install -v -d -m755 /etc/xml &&
    xmlcatalog --noout --create /etc/xml/catalog
fi &&

xmlcatalog --noout --add "delegatePublic"             \
  "-//OASIS//DTD DocBook XML 5.0//EN                " \
  "file:///usr/share/xml/docbook/xml-5.0/catalog.xml" \
  /etc/xml/catalog &&

xmlcatalog --noout --add "delegateSystem"             \
  "http://docbook.org/xml/5.0/dtd/"                   \
  "file:///usr/share/xml/docbook/xml-5.0/catalog.xml" \
  /etc/xml/catalog &&

xmlcatalog --noout --add "delegateURI"                \
  "http://docbook.org/xml/5.0"                        \
  "file:///usr/share/xml/docbook/xml-5.0/catalog.xml" \
  /etc/xml/catalog

cd "$ARYA_SOURCES"
rm -rf "$srcdir"
