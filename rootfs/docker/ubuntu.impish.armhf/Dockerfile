FROM ubuntu:impish

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV DISTRO impish

ENV ARCH armhf
ENV ABI arm-linux-gnueabihf

# Prep host
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install host deps
RUN apt update && \
        apt install -y \
            debootstrap \
            gcc-${ABI} \
            g++-${ABI} \
            qemu-user-static \
            libglib2.0-dev \
            curl \
            ruby \
            ruby-dev \
            rubygems \
            git \
            python3-setuptools \
            python3-pip \
            pkg-config \
            make \
            protobuf-c-compiler \
            protobuf-compiler \
        && \
        gem install --no-document fpm 

RUN /usr/sbin/debootstrap --arch=${ARCH} --components=main,contrib,non-free,restricted,universe,multiverse ${DISTRO} /sysroot && \
        chroot /sysroot sh -c \
            'echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
                apt update && \
                apt-get install -y \
                    libc6-dev \
                    libwebsockets-dev \
                    pkg-config \
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

