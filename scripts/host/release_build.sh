#!/bin/bash -e

if test $# -ne 4; then
	echo "Expected [builddir] [srcdir] [tag] [version]"
	exit
fi

export BASE_DIR=$1
export SRC_DIR=$2

export CHECKOUT=$3
export VERSION=$4

export NCORES=$(nproc)

. "${BASE_DIR}/scripts/host/platform"

if [ ! -d scripts/build-${VERSION} ]; then
    cp -rv scripts/build-master scripts/build-${VERSION}
    git add scripts/build-${VERSION}
fi

if [ ! -d scripts/fpm-${VERSION} ]; then
    cp -rv scripts/fpm-master scripts/fpm-${VERSION}
    git add scripts/fpm-${VERSION}
fi

for d in ${BASE_DIR}/docker/*; do
    echo
    echo
	echo BUILDING $d
    echo
    echo

	pushd $d
    _PLATFORM_MAKE_PKG_DIR "${BASE_DIR}" docker-compose.yaml
    make kismet-release
	popd
done

# ${BASE_DIR}/scripts/host/aptly_update_release_repos.sh "${BASE_DIR}" "${VERSION}"

