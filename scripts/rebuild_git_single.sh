#!/bin/bash -e

if test $# -ne 5; then
    echo "Expected [base] [src] [docker] [distro] [platform]"
	exit
fi

export BASE_DIR=${BASE_DIR:-$1}
export SRC_DIR=${SRC_DIR:-$2}
export NCORES=$(nproc)

rm -vf ${BASE_DIR}/dpkgs-${4}/*git*${5}.deb

pushd ${BASE_DIR}/docker/$(basename "${3}")
/usr/bin/time docker-compose run -e NCORES -e BASE_DIR -e SRC_DIR kismet-build 2>&1
popd

