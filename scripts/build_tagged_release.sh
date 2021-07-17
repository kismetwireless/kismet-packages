#!/bin/bash -e

if test $# -ne 2; then
	echo "Expected [tag] [version]"
	exit
fi


# rm -vf ${BASE_DIR}/dpkgs-*/*.deb

export CHECKOUT=$1
export VERSION=$2

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
    docker-compose run -e CHECKOUT -e VERSION -e NCORES kismet-build 2>&1 | tee ${BASE_DIR}/logs/$(basename ${d}.release)
	popd
done

${BASE_DIR}/scripts/aptly_update_release_repos.sh "${VERSION}"

