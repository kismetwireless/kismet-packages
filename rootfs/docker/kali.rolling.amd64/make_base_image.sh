#!/bin/bash -e

ARCH=amd64

curl "https://gitlab.com/kalilinux/packages/debootstrap/raw/kali/master/scripts/kali" > kali-debootstrap

sudo debootstrap --arch=${ARCH} kali-rolling /tmp/kali-rolling-${ARCH} https://http.kali.org/kali ./kali-debootstrap

sudo tar -C /tmp/kali-rolling-${ARCH} -c . | docker import - kali-rolling-${ARCH}

