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

if [ ! -d scripts/build-${VERSION} ]; then
    cp -rv scripts/build-master scripts/build-${VERSION}
    git add scripts/build-${VERSION}
fi

if [ ! -d scripts/fpm-${VERSION} ]; then
    cp -rv scripts/fpm-master scripts/fpm-${VERSION}
    git add scripts/fpm-${VERSION}
fi

for d in ${BASE_DIR}/docker/*; do
	echo $d
	pushd $d
    make kismet-release
	popd
done

#${BASE_DIR}/scripts/aptly_update_release_repos.sh "${BASEDIR}" "${VERSION}"

