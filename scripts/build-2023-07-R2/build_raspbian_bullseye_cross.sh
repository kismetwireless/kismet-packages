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

# Kluge the path
export PATH=$PATH:/opt/cross-pi-gcc-10.2.0-0/bin/

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
    LDFLAGS="--sysroot=/sysroot" \
    --prefix=/usr \
    --sysconfdir=/etc/kismet \
    --disable-element-typesafety 

if [ "${NCORES}" = "" ]; then 
	NCORES=$(nproc)
fi
make -j${NCORES}

/tmp/fpm/fpm_debian_bullseye.sh
/tmp/fpm/fpm_noarch_python3_deb.sh

# Build wifi coconut 
# cd /build 
# git clone https://github.com/hak5/hak5-wifi-coconut
# cd hak5-wifi-coconut 
# mkdir build 
# cd build 
# cmake ../ -DCMAKE_INSTALL_PREFIX=/usr
# make -j${NCORES} 
# /tmp/fpm/fpm_raspbian_bullseye_coconut.sh

mv -v *.deb /dpkgs

