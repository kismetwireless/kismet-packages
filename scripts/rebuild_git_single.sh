#!/bin/bash -e

if test $# -ne 3; then
    echo "Expected [docker] [distro] [platform]"
	exit
fi

BASE_DIR=${BASE_DIR:-'.'}

rm -vf ${BASE_DIR}/dpkgs-${2}/*git*${3}.deb

export NCORES=$(nproc)

pushd ${BASE_DIR}/docker/$(basename "${1}")
echo $d
/usr/bin/time docker-compose run -e NCORES kismet-build 2>&1
popd

