#!/bin/sh
# Unpack an exported container filesystem from stdin into the sysroot with a
# native tar, then rewrite absolute symlinks to point inside the sysroot.
# Emulated tools can't be used: resolute's tar needs syscalls qemu-user lacks.

set -e

SYSROOT=/mnt/sysroot

tar x -C "${SYSROOT}" --anchored \
    --exclude=dev --exclude=proc --exclude=sys --exclude=mnt

cd "${SYSROOT}"
find . -type l -lname '/*' | while IFS= read -r link; do
    target=$(readlink "${link}")
    rel=$(realpath -m -s --relative-to="$(dirname "${link}")" "${SYSROOT}${target}")
    ln -sfn "${rel}" "${link}"
done
