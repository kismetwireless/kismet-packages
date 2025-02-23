# Modified to generate an arm64 container on the host, so we can map it into
# the docker.
#
# There is a long-standing bug in qemu-aarch64 that makes it segv python
# when running inside an environment like a docker, making it impossible
# to do the sysroot install inside the docker
#

container:
	docker build -t kismet/mantic_arm64 -f Dockerfile-arm64 .
	docker volume create kismet_mantic_arm64_sysroot
	docker run --rm \
		--mount source=kismet_mantic_arm64_sysroot,target=/mnt/sysroot \
		kismet/mantic_arm64:latest \
		sh -c "/usr/bin/tar \
		--exclude=/mnt \
		--exclude=/dev \
		--exclude=/proc \
		--exclude=/sys \
		-chv / | tar x -C /mnt/sysroot/"
	docker compose build --no-cache

kismet:
	@docker compose run --rm -e NCORES kismet-build

kismet-release:
	@docker compose run --rm -e CHECKOUT -e VERSION -e NCORES kismet-build

shell:
	@docker compose run --rm kismet-build /bin/bash
