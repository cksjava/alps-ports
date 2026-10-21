#!/bin/bash
# AryaLinux package build
# 7zip — 7zip-26.02
# Instructions follow the book. Test-suite commands are omitted.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

# shellcheck disable=SC1091
source /var/lib/alps/env.sh

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

echo "=== 7zip-26.02 ==="
cd "$ARYA_SOURCES"
tarball="7zip-26.02.tar.gz"
if [[ ! -f "$tarball" ]]; then
    echo "Missing source archive: $ARYA_SOURCES/$tarball" >&2
    exit 1
fi
srcdir=$(tar -tf "$tarball" | awk -F/ 'NR==1 { print $1 }')
rm -rf "$srcdir"
tar -xf "$tarball"
cd "$srcdir"

sed -i 's/-Werror //g' CPP/7zip/7zip_gcc.mak
(for i in Bundles/{Alone,Alone7z,Format7zF,SFXCon} UI/Console; do
    make -C CPP/7zip/$i -f ../../cmpl_gcc.mak || exit
done)
install -vDm755 CPP/7zip/Bundles/Alone{/b/g/7za,7z/b/g/7zr} \
                CPP/7zip/Bundles/Format7zF/b/g/7z.so        \
                CPP/7zip/UI/Console/b/g/7z                  \
                -t /usr/lib/7zip/                           &&

install -vm755 CPP/7zip/Bundles/SFXCon/b/g/7zCon \
               /usr/lib/7zip/7zCon.sfx           &&

(for i in 7z 7za 7zr; do
    cat > /usr/bin/$i << EOF || exit
#!/bin/sh
exec /usr/lib/7zip/$i "\$@"
EOF
    chmod 755 /usr/bin/$i || exit
done) &&

cp -rv DOC -T /usr/share/doc/7zip-26.02

cd "$ARYA_SOURCES"
rm -rf "$srcdir"

