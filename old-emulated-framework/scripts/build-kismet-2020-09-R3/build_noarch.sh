#!/bin/sh -e

cd /build

git clone --recursive https://www.kismetwireless.net/git/kismet.git
cd kismet

if [ "${CHECKOUT}"x != "x" ]; then
	echo "Checking out ${CHECKOUT}"
	git checkout ${CHECKOUT}
fi

./configure --prefix=/usr --sysconfdir=/etc/kismet

/tmp/fpm/fpm_noarch_python3_deb.sh

mv -v *.deb /dpkgs

