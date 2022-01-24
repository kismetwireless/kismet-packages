#!/bin/bash -e

BASE_DIR=${BASE_DIR:-'.'}

rm -vf ${BASE_DIR}/dpkgs-*/*git*.deb
rm -vf ${BASE_DIR}/logs/*.last

export NCORES=$(nproc)

for d in ${BASE_DIR}/docker/*; do
	echo $d
	pushd $d
	/usr/bin/time make kismet 2>&1 | tee ${BASE_DIR}/logs/$(basename ${d}.last)
	popd
done

