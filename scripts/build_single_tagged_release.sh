#!/bin/bash -e

BASE_DIR=${BASE_DIR:-$1}
SRC_DIR=${SRC_DIR:-$2}
export BASE_DIR
export SRC_DIR

if test $# -ne 5; then
	echo "Expected [builddir] [srcdir] [tag] [version] [build]"
	exit
fi


# rm -vf ${BASE_DIR}/dpkgs-*/*.deb

export CHECKOUT=$3
export VERSION=$4

export NCORES=$(nproc)

pushd ${BASE_DIR}/docker/$(basename "${5}")
docker-compose run -e CHECKOUT -e VERSION -e NCORES kismet-build 2>&1 | tee ${BASE_DIR}/logs/$(basename ${5}.release)
docker-compose rm
popd

