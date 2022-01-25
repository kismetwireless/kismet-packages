#!/bin/bash -e

ARCH=armel

curl "https://git.kali.org/gitweb/?p=packages/debootstrap.git;a=blob_plain;f=scripts/kali;hb=HEAD" > kali-debootstrap

sudo qemu-debootstrap --include=kali-archive-keyring --arch=${ARCH} kali-rolling /tmp/kali-rolling-${ARCH} https://http.kali.org/kali ./kali-debootstrap

sudo tar -C /tmp/kali-rolling-${ARCH} -c . | docker import - kali-rolling-${ARCH}

