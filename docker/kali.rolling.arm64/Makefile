# Modified to generate an arm64 container on the host, so we can map it into
# the docker.
#
# There is a long-standing bug in qemu-aarch64 that makes it segv python
# when running inside an environment like a docker, making it impossible
# to do the sysroot install inside the docker
#

DISTRO=kali_rolling
ARCH=arm64

container:
	docker build --no-cache -t kismet/${DISTRO}_${ARCH} -f Dockerfile-${ARCH} .
	docker volume create kismet_${DISTRO}_${ARCH}_sysroot
	docker run --rm \
		--mount source=kismet_${DISTRO}_${ARCH}_sysroot,target=/mnt/sysroot \
		kismet/${DISTRO}_${ARCH}:latest \
		sh -c "/usr/bin/tar \
		--exclude=/mnt \
		--exclude=/dev \
		--exclude=/proc \
		--exclude=/sys \
		-chv / | tar x -C /mnt/sysroot/"
	docker-compose build --no-cache

kismet:
	@docker-compose run --rm -e NCORES kismet-build

kismet-release:
	@docker-compose run --rm -e CHECKOUT -e VERSION -e NCORES kismet-build

shell:
	@docker-compose run --rm kismet-build /bin/bash

armshell:
	docker build -t kismet/${DISTRO}_${ARCH} -f Dockerfile-${ARCH} .
	docker run --rm \
		--mount source=kismet_${DISTRO}_${ARCH}_sysroot,target=/mnt/sysroot \
		kismet/${DISTRO}_${ARCH}:latest \
		/bin/bash
