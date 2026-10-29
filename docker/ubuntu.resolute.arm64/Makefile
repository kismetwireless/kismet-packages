# Modified to generate an arm64 container on the host, so we can map it into
# the docker.
#
# There is a long-standing bug in qemu-aarch64 that makes it segv python
# when running inside an environment like a docker, making it impossible
# to do the sysroot install inside the docker
#
# The sysroot is copied out with docker export and a native tar; resolute's
# own tar uses syscalls the host qemu-aarch64 doesn't implement.
#

container:
	-docker image rm kismet/resolute_arm64
	docker pull --platform linux/arm64 arm64v8/ubuntu:resolute
	docker build --pull --platform linux/arm64/v8 -t kismet/resolute_arm64 -f Dockerfile-arm64 .
	-docker rm kismet_resolute_arm64_export
	-docker volume rm kismet_resolute_arm64_sysroot
	docker volume create kismet_resolute_arm64_sysroot
	docker create --name kismet_resolute_arm64_export kismet/resolute_arm64:latest
	docker export kismet_resolute_arm64_export | docker run --rm -i \
		--platform linux/amd64 \
		--mount source=kismet_resolute_arm64_sysroot,target=/mnt/sysroot \
		--mount type=bind,source=$(CURDIR)/sysroot-extract.sh,target=/sysroot-extract.sh,readonly \
		debian:bookworm sh /sysroot-extract.sh
	docker rm kismet_resolute_arm64_export
	docker compose build --pull --no-cache

kismet:
	@docker compose run --rm -e NCORES kismet-build

kismet-release:
	@docker compose run --rm -e CHECKOUT -e VERSION -e NCORES kismet-build

shell:
	@docker compose run --rm kismet-build /bin/bash
