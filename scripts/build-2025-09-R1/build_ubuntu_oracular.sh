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

if test "${CHECKOUT}"x = "HEADx"; then
    touch /dpkgs/last_git_${ARCH}

    if test "$(cat /dpkgs/last_git_${ARCH})" = "$(git rev-parse --short HEAD)"; then
        echo "*** No build required ***"
        exit 0
    fi

    echo "*** Cleaning old git packages ***"
    rm -vf ${BASE_DIR}/dpkgs/*git*${ARCH}.deb

    echo -n "$(git rev-parse --short HEAD)" > /dpkgs/last_git_${ARCH}
fi

./configure \
    --prefix=/usr \
    --sysconfdir=/etc/kismet \
    --disable-element-typesafety \
    --enable-protobuf \
    --enable-bladerf \
    --enable-wifi-coconut


if [ "${NCORES}" = "" ]; then 
	NCORES=$(nproc)
fi
make -j${NCORES} || { rm /dpkgs/last_git_${ARCH}; echo "*** FAILED ***"; exit; }

/tmp/fpm/fpm_ubuntu_oracular.sh || { rm /dpkgs/last_git_${ARCH}; echo "*** FAILED ***"; exit; }

mv -v *.deb /dpkgs

# Build wifi coconut 

cd /build 
git config --global --add safe.directory /build/hak5-wifi-coconut/.git
git clone https://github.com/hak5/hak5-wifi-coconut
cd hak5-wifi-coconut 
mkdir build 
cd build 
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr
make -j${NCORES} 
/tmp/fpm/fpm_ubuntu_oracular_coconut.sh

mv -v *.deb /dpkgs

