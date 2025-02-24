#!/bin/bash -e

if test $# -ne 5; then
    echo "Expected [base] [src] [docker] [distro] [platform]"
	exit
fi

export BASE_DIR=$1
export SRC_DIR=$2
export NCORES=$(nproc)

pushd ${BASE_DIR}/docker/$(basename "${3}")
make kismet 
popd

