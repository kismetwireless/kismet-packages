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

export PKG_CONFIG_DIR=""
export PKG_CONFIG_PATH="/sysroot/usr/lib/pkgconfig:/sysroot/usr/share/pkgconfig:/sysroot/usr/lib/${ABI}/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="/sysroot"

export AR=${ABI}-ar
export CC=${ABI}-gcc
export CXX=${ABI}-g++ 

./configure \
    --build=x86_64-linux \
    --host=${ABI} \
    CFLAGS="-I/sysroot/usr/include -I/sysroot/usr/include/${ABI}" \
    CPPFLAGS="-I/sysroot/usr/include -I/sysroot/usr/include/${ABI}" \
    CXXFLAGS="-I/sysroot/usr/include -I/sysroot/usr/include/${ABI}" \
    LDFLAGS="-L/sysroot/usr/lib/${ABI} --sysroot=/sysroot" \
    --prefix=/usr \
    --sysconfdir=/etc/kismet \
    --disable-element-typesafety \
    --enable-wifi-coconut \
    --enable-bladerf

if [ "${NCORES}" = "" ]; then 
	NCORES=$(nproc)
fi
make -j${NCORES}

/tmp/fpm/fpm_kali.sh
#/tmp/fpm/fpm_kali_python3_deb.sh

mv -v *.deb /dpkgs

