#!/bin/bash
# AryaLinux package build
# ttf-and-otf-fonts — TTF and OTF fonts
# Downloads Google Fonts and the families named on the TTF and OTF fonts page.
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
# shellcheck disable=SC1091
source /var/lib/alps/alpslib.sh

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

echo "=== TTF and OTF fonts ==="

cache="${ARYA_SOURCES}/ttf-and-otf-fonts"
work="${cache}/unpack"
mkdir -p "$cache" "$work"

fetch() {
    local url="$1" dest="$2"
    if [[ -s "$dest" ]]; then
        return
    fi
    curl -fL --retry 3 --retry-delay 2 -o "${dest}.partial" "$url"
    mv "${dest}.partial" "$dest"
}

install_fonts() {
    local family="$1" root="$2"
    local dest="/usr/share/fonts/${family}"
    local found=0
    install -d -m755 "$dest"
    while IFS= read -r -d '' file; do
        install -m644 "$file" "${dest}/$(basename "$file")"
        found=1
    done < <(find "$root" -type f \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' -o -iname '*.otc' \) -print0)
    if [[ "$found" -eq 0 ]]; then
        echo "No TTF or OTF files in ${family}" >&2
        exit 1
    fi
    find "$dest" -type d -exec chmod 755 {} +
    find "$dest" -type f -exec chmod 644 {} +
}

unpack_archive() {
    local archive="$1" dest="$2"
    rm -rf "$dest"
    mkdir -p "$dest"
    bsdtar -xf "$archive" -C "$dest"
    local nested
    nested=$(find "$dest" -maxdepth 3 -type f -name 'data.tar.*' -print -quit || true)
    if [[ -n "$nested" ]]; then
        bsdtar -xf "$nested" -C "$dest"
    fi
}

archive_font() {
    local family="$1" url="$2" filename="$3"
    local archive="${cache}/${filename}"
    local dest="${work}/${family}"
    fetch "$url" "$archive"
    unpack_archive "$archive" "$dest"
    install_fonts "$family" "$dest"
}

google_font() {
    local family="$1" spec="$2"
    local css="${cache}/${family}.css"
    local dest="${work}/${family}"
    mkdir -p "$dest"
    if [[ ! -s "$css" ]]; then
        curl -fL --retry 3 --retry-delay 2 -A curl -o "${css}.partial" \
            "https://fonts.googleapis.com/css2?family=${spec}&display=swap"
        mv "${css}.partial" "$css"
    fi
    if grep -q "format('woff" "$css"; then
        echo "Google Fonts returned a web font for ${family}" >&2
        exit 1
    fi
    local count=0
    while read -r style weight url; do
        count=$((count + 1))
        local file="${dest}/${family}-${style}-${weight}-${count}.ttf"
        if [[ ! -s "$file" ]]; then
            curl -fL --retry 3 --retry-delay 2 -A curl -o "${file}.partial" "$url"
            mv "${file}.partial" "$file"
        fi
    done < <(awk '
        /font-style:/ { style = $2; gsub(/;/, "", style) }
        /font-weight:/ { weight = $2; gsub(/;/, "", weight) }
        /url\(https:\/\/fonts\.gstatic\.com/ {
            url = $0
            sub(/.*url\(/, "", url)
            sub(/\).*/, "", url)
            print style, weight, url
        }
    ' "$css")
    if [[ "$count" -eq 0 ]]; then
        echo "Google Fonts returned no files for ${family}" >&2
        exit 1
    fi
    install_fonts "$family" "$dest"
}

# Static instances from Google Fonts. Noto Sans includes the nine weights
# the book describes. The other families install regular, bold, and italic.
google_font noto-sans "Noto+Sans:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900"
google_font noto-serif "Noto+Serif:ital,wght@0,400;0,700;1,400;1,700"
google_font noto-sans-mono "Noto+Sans+Mono:wght@400;700"
google_font noto-sans-sc "Noto+Sans+SC:wght@400;700"
google_font noto-sans-tc "Noto+Sans+TC:wght@400;700"
google_font noto-sans-hk "Noto+Sans+HK:wght@400;700"
google_font noto-sans-jp "Noto+Sans+JP:wght@400;700"
google_font noto-sans-kr "Noto+Sans+KR:wght@400;700"
google_font caladea "Caladea:ital,wght@0,400;0,700;1,400;1,700"
google_font cantarell "Cantarell:ital,wght@0,400;0,700;1,400;1,700"
google_font carlito "Carlito:ital,wght@0,400;0,700;1,400;1,700"
google_font gelasio "Gelasio:ital,wght@0,400;0,700;1,400;1,700"
google_font roboto "Roboto:ital,wght@0,400;0,700;1,400;1,700"
google_font roboto-mono "Roboto+Mono:ital,wght@0,400;0,700;1,400;1,700"
google_font open-sans "Open+Sans:ital,wght@0,400;0,700;1,400;1,700"

# Families named on the TTF and OTF fonts page. OpenType is used where the
# upstream publishes it. Source Code Pro comes from the Adobe release.
archive_font source-code-pro \
    "https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u%2F1.062R-i%2F1.026R-vf/OTF-source-code-pro-2.042R-u_1.062R-i.zip" \
    "source-code-pro-otf.zip"
archive_font adwaita \
    "https://download.gnome.org/sources/adwaita-fonts/49/adwaita-fonts-49.0.tar.xz" \
    "adwaita-fonts-49.0.tar.xz"
archive_font dejavu \
    "https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_2_37/dejavu-fonts-ttf-2.37.tar.bz2" \
    "dejavu-fonts-ttf-2.37.tar.bz2"
archive_font freefont \
    "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz" \
    "freefont-otf-20120503.tar.gz"
archive_font liberation \
    "https://deb.debian.org/debian/pool/main/f/fonts-liberation/fonts-liberation_2.1.5-3_all.deb" \
    "fonts-liberation_2.1.5-3_all.deb"
archive_font hack \
    "https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip" \
    "Hack-v3.003-ttf.zip"
# Lohit upstream publishes FontForge sources. The Debian packages contain the built TTF.
archive_font lohit-deva \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-deva/fonts-lohit-deva_2.95.4-7_all.deb" \
    "fonts-lohit-deva_2.95.4-7_all.deb"
archive_font lohit-gujr \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-gujr/fonts-lohit-gujr_2.92.4-6_all.deb" \
    "fonts-lohit-gujr_2.92.4-6_all.deb"
archive_font lohit-guru \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-guru/fonts-lohit-guru_2.91.2-4_all.deb" \
    "fonts-lohit-guru_2.91.2-4_all.deb"
archive_font lohit-knda \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-knda/fonts-lohit-knda_2.5.4-4_all.deb" \
    "fonts-lohit-knda_2.5.4-4_all.deb"
archive_font lohit-mlym \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-mlym/fonts-lohit-mlym_2.92.2-3_all.deb" \
    "fonts-lohit-mlym_2.92.2-3_all.deb"
archive_font lohit-orya \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-orya/fonts-lohit-orya_2.91.2-3_all.deb" \
    "fonts-lohit-orya_2.91.2-3_all.deb"
archive_font lohit-taml \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-taml/fonts-lohit-taml_2.91.3-3_all.deb" \
    "fonts-lohit-taml_2.91.3-3_all.deb"
archive_font lohit-telu \
    "https://deb.debian.org/debian/pool/main/f/fonts-lohit-telu/fonts-lohit-telu_2.5.5-3_all.deb" \
    "fonts-lohit-telu_2.5.5-3_all.deb"
archive_font wqy-zenhei \
    "https://deb.debian.org/debian/pool/main/f/fonts-wqy-zenhei/fonts-wqy-zenhei_0.9.45.orig.tar.gz" \
    "wqy-zenhei-0.9.45.orig.tar.gz"
archive_font uming \
    "https://deb.debian.org/debian/pool/main/f/fonts-arphic-uming/fonts-arphic-uming_0.2.20080216.2.orig.tar.bz2" \
    "fonts-arphic-uming_0.2.20080216.2.orig.tar.bz2"
archive_font opendesktop \
    "https://sources.archlinux.org/other/opendesktop-fonts/opendesktop-fonts-1.4.2.tar.gz" \
    "opendesktop-fonts-1.4.2.tar.gz"
archive_font ipaex \
    "https://deb.debian.org/debian/pool/main/f/fonts-ipaexfont/fonts-ipaexfont_00401.orig.tar.gz" \
    "fonts-ipaexfont_00401.orig.tar.gz"
archive_font vlgothic \
    "https://deb.debian.org/debian/pool/main/f/fonts-vlgothic/fonts-vlgothic_20220612.orig.tar.xz" \
    "fonts-vlgothic_20220612.orig.tar.xz"
archive_font nanum \
    "https://deb.debian.org/debian/pool/main/f/fonts-nanum/fonts-nanum_20250212.orig.tar.xz" \
    "fonts-nanum_20250212.orig.tar.xz"
archive_font un-fonts \
    "https://deb.debian.org/debian/pool/main/f/fonts-unfonts-core/fonts-unfonts-core_1.0.2-080608.orig.tar.xz" \
    "fonts-unfonts-core_1.0.2-080608.orig.tar.xz"

fc-cache -f /usr/share/fonts
