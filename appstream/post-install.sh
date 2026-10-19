#!/bin/bash
# AryaLinux post-install
# appstream — AppStream-1.1.6
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

install -vdm755 /usr/share/metainfo &&
cat > /usr/share/metainfo/org.linuxfromscratch.lfs.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="operating-system">
  <id>org.linuxfromscratch.lfs</id>
  <name>Linux From Scratch</name>
  <summary>A customized Linux system built entirely from source</summary>
  <description>
    <p>
      Linux From Scratch (LFS) is a project that provides you with
      step-by-step instructions for building your own customized Linux
      system entirely from source.
    </p>
  </description>
  <url type="homepage">https://www.linuxfromscratch.org/lfs/</url>
  <metadata_license>MIT</metadata_license>
  <developer id='linuxfromscratch.org'>
    <name>The Linux From Scratch Editors</name>
  </developer>

  <releases>
    <release version="13.1" type="stable" date="2026-09-03">
      <description>
        <p>Now contains Binutils 2.47, GCC-16.2.0, Glibc-2.44,
        Linux kernel 7.1.8, and numerous security updates.</p>
      </description>
    </release>

  <releases>
    <release version="13.0" type="stable" date="2026-03-05">
      <description>
        <p>Now contains Binutils 2.46.0, GCC-15.2.0, Glibc-2.43,
        Linux kernel 6.18, and six security updates.</p>
      </description>
    </release>

    <release version="12.4" type="stable" date="2025-09-01">
      <description>
        <p>Now contains Binutils 2.45, GCC-15.2.0, Glibc-2.42,
        Linux kernel 6.16, and twelve security updates.</p>
      </description>
    </release>

    <release version="12.3" type="stable" date="2025-03-05">
      <description>
        <p>Now contains Binutils 2.44, GCC-14.2.0, Glibc-2.41, and
        Linux Kernel 6.13, and three security updates.</p>
      </description>
    </release>
  </releases>
</component>
EOF
