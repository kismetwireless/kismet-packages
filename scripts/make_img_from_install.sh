#!/bin/bash -e

sudo kpartx -arv "$1"
echo -n "Loop number: "
read LOOPDEV
sudo mkdir -p /mnt/loop
sudo mount /dev/mapper/loop${LOOPDEV}p2 /mnt/loop
sudo tar -C /mnt/loop -c . | docker import - "$(basename $1)"
sudo umount /mnt/loop
sudo kpartx -dv "$1"

echo "Image created as $(basename $1)"

