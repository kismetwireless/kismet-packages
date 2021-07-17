#!/bin/sh -e

cd /build

#git clone --recursive https://www.kismetwireless.net/git/kismet.git
git clone --recursive /kismet
cd kismet

if [ "${CHECKOUT}"x != "x" ]; then
	echo "Checking out ${CHECKOUT}"
	git checkout ${CHECKOUT}
fi

./configure --prefix=/usr --sysconfdir=/etc/kismet

if [ "${NCORES}" = "" ]; then 
	NCORES=$(($(nproc) / 2))
fi
make -j${NCORES}

/tmp/fpm/fpm_cosmic.sh
/tmp/fpm/fpm_noarch_python3_deb.sh

mv -v *.deb /dpkgs

