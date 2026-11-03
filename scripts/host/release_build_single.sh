#!/bin/bash -e

export BASE_DIR=$1
export SRC_DIR=$2

if test $# -ne 5; then
	echo "Expected [builddir] [srcdir] [tag] [version] [build]"
	exit
fi

export CHECKOUT=$3
export VERSION=$4

export NCORES=$(nproc)

. "${BASE_DIR}/scripts/host/platform"

pushd ${BASE_DIR}/docker/$(basename "${5}")
_PLATFORM_MAKE_PKG_DIR "${BASE_DIR}" docker-compose.yaml
make kismet-release
popd

