#!/bin/bash -e

BASE_DIR=${BASE_DIR:-'.'}

if test $# -ne 3; then
	echo "Expected [tag] [version] [build]"
	exit
fi


# rm -vf ${BASE_DIR}/dpkgs-*/*.deb

export CHECKOUT=$1
export VERSION=$2

export NCORES=$(nproc)

pushd ${BASE_DIR}/docker/$(basename "${3}")
docker-compose run -e CHECKOUT -e VERSION -e NCORES kismet-build 2>&1 | tee ${BASE_DIR}/logs/$(basename ${3}.release)
popd

