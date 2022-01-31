FROM debian:bullseye

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV DISTRO bullseye
ENV DEBOOT http://raspbian.raspberrypi.org/raspbian/

ENV ARCH armhf
ENV ABI arm-linux-gnueabihf

ENV KEYSRC http://raspbian.raspberrypi.org/raspbian/pool/main/r/raspbian-archive-keyring/
ENV KEYFILE raspbian-archive-keyring_20120528.2_all.deb

ENV XTOOL https://sourceforge.net/projects/raspberry-pi-cross-compilers/files/Raspberry%20Pi%20GCC%20Cross-Compiler%20Toolchains/Bullseye/GCC%2010.2.0/Raspberry%20Pi%201%2C%20Zero
ENV XTOOLTGZ cross-gcc-10.2.0-pi_0-1

# Prep host
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install host deps
RUN apt update && \
        apt install -y \
            debootstrap \
            qemu-user-static \
            curl \
            ruby \
            ruby-dev \
            rubygems \
            git \
            libglib2.0-dev \
            python3-setuptools \
            pkg-config \
            python3-pip \
            make \
            protobuf-c-compiler \
            protobuf-compiler \
        && \
        gem install --no-document fpm 

#COPY bullseye.ports.sources /bullseye.sources    
#cp /bullseye.sources /sysroot/etc/apt/sources.list && \
RUN curl -LO ${KEYSRC}{$KEYFILE} && \
        dpkg -i ${KEYFILE} && \
        /usr/sbin/debootstrap --keyring=/usr/share/keyrings/raspbian-archive-keyring.gpg --arch=${ARCH} --components=main,contrib,non-free,restricted,universe,multiverse ${DISTRO} /sysroot ${DEBOOT} && \
        chroot /sysroot sh -c \
            'echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
                apt update && \
                rm -rf /etc/ssl/certs/*.pem && \
                apt install --reinstall -y ssl-cert && \
                apt install --reinstall -y ca-certificates && \
                apt-get install -y \
                    libc6-dev \
                    libwebsockets-dev \
                    zlib1g-dev \
                    libnl-3-dev \
                    libnl-genl-3-dev \
                    libcap-dev \
                    libpcap-dev \
                    libnm-dev \
                    libdw-dev \
                    libsqlite3-dev \
                    libprotobuf-dev \
                    libprotobuf-c-dev \
                    libsensors4-dev \
                    librtlsdr0 \
                    libusb-1.0-0-dev \
                    libubertooth-dev \
                    libbtbb-dev \
                    libubertooth1 \
                    libbtbb1 \
                ' && \
        cd /sysroot/lib/${ABI} && find ./ -name '*.so*' -lname '/*' -exec sh -c 'export TARGET=$(basename $(readlink $0)); rm $0; ln -snf "$TARGET" "$(basename "$0")";' {} \; 

# Get the armv6 toolchain
RUN curl -LO "${XTOOL}/${XTOOLTGZ}.tar.gz" && \
        tar xvf ${XTOOLTGZ}.tar.gz -C /opt && \
        ln -s /sysroot/usr/lib/${ABI} /sysroot/usr/lib/${ABI}/10.2.0 && \
        echo "/lib/${ABI}" > /etc/ld.so.conf.d/sysroot.conf && \
        echo "/usr/lib/${ABI}" > /etc/ld.so.conf.d/sysroot.conf 

