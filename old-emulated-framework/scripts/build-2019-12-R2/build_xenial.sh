#!/bin/sh -e

cd /build

git clone --recursive https://www.kismetwireless.net/git/kismet.git
cd kismet

if [ "${CHECKOUT}"x != "x" ]; then
	echo "Checking out ${CHECKOUT}"
	git checkout ${CHECKOUT}
fi

./configure --prefix=/usr --sysconfdir=/etc/kismet --disable-python-tools

if [ "${NCORES}" = "" ]; then 
	NCORES=$(($(nproc) / 2))
fi
make -j${NCORES}

/tmp/fpm/fpm_xenial.sh

mv -v *.deb /dpkgs

