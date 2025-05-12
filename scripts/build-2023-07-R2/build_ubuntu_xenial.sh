#!/bin/sh -e

cd /build

git config --global --add safe.directory /kismet/.git

git clone --recursive /kismet
cd kismet
git checkout master

if [ "${CHECKOUT}"x != "x" ]; then
	echo "Checking out ${CHECKOUT}"
	git checkout ${CHECKOUT}
fi


./configure \
    --prefix=/usr \
    --sysconfdir=/etc/kismet \
    --disable-element-typesafety \
    --disable-python-tools \
    --disable-libwebsockets 


if [ "${NCORES}" = "" ]; then 
	NCORES=$(nproc)
fi
make -j${NCORES}

/tmp/fpm/fpm_ubuntu_xenial.sh

mv -v *.deb /dpkgs

