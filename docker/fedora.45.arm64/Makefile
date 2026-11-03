# Generates an arm64 Fedora container on the host and copies it into the
# sysroot volume the cross build container mounts.
#
# The copy is exported by docker and unpacked natively: Fedora's tar uses
# syscalls older qemu-user doesn't implement.  Absolute symlinks are made
# relative so they resolve inside the sysroot wherever it is mounted.

DISTRO=fedora_45
ARCH=arm64
SYSROOT=kismet_${DISTRO}_${ARCH}_sysroot
EXPORT=kismet_${DISTRO}_${ARCH}_export

container:
	docker pull --platform linux/arm64 fedora:45
	docker build --pull --platform linux/arm64 -t kismet/${DISTRO}_${ARCH} -f Dockerfile-${ARCH} .
	-docker rm -f ${EXPORT}
	-docker volume rm ${SYSROOT}
	docker volume create ${SYSROOT}
	docker create --platform linux/arm64 --name ${EXPORT} kismet/${DISTRO}_${ARCH}:latest
	docker export ${EXPORT} | docker run --rm -i --pull always --platform linux/amd64 \
		--mount source=${SYSROOT},target=/mnt/sysroot \
		fedora:45 sh -c ' \
		tar x -C /mnt/sysroot --anchored --exclude=dev --exclude=proc --exclude=sys && \
		find /mnt/sysroot -type l -lname "/*" | while read -r l; do \
			ln -snf "$$(realpath -m --relative-to="$$(dirname "$$l")" "/mnt/sysroot$$(readlink "$$l")")" "$$l"; \
		done'
	docker rm -f ${EXPORT}
	docker compose build --pull --no-cache

kismet:
	@docker compose run --rm -e NCORES kismet-build

kismet-release:
	@docker compose run --rm -e CHECKOUT -e VERSION -e NCORES kismet-build

shell:
	@docker compose run --rm kismet-build /bin/bash
