#!/bin/sh -e

cd /build

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
    --enable-wifi-coconut
    # --enable-bladerf \


if [ "${NCORES}" = "" ]; then 
	NCORES=$(nproc)
fi
make -j${NCORES}

/tmp/fpm/fpm_ubuntu_jammy.sh
/tmp/fpm/fpm_ubuntu_jammy_python3_deb.sh

mv -v *.deb /dpkgs

# Build wifi coconut 

cd /build 
git clone https://github.com/hak5/hak5-wifi-coconut
cd hak5-wifi-coconut 
mkdir build 
cd build 
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr
make -j${NCORES} 
/tmp/fpm/fpm_ubuntu_jammy_coconut.sh

mv -v *.deb /dpkgs

