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

ENV PB https://github.com/protocolbuffers/protobuf/releases/download/
ENV PBV 3.12.4

# Prep host
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install host deps
RUN apt update && \
        apt install -y \
            debootstrap \
            gcc-${ABI} \
            g++-${ABI} \
            qemu-user-static \
            curl \
            ruby \
            ruby-dev \
            rubygems \
            git \
            python3-setuptools \
            pkg-config \
            python3-pip \
            make \
            protobuf-c-compiler \
        && \
        gem install --no-document fpm && \
        ln -s /usr/bin/${ABI}-ar /usr/bin/ar

#COPY bullseye.ports.sources /bullseye.sources    
#cp /bullseye.sources /sysroot/etc/apt/sources.list && \
RUN curl -LO ${KEYSRC}{$KEYFILE} && \
        dpkg -i ${KEYFILE} && \
        /usr/sbin/debootstrap --keyring=/usr/share/keyrings/raspbian-archive-keyring.gpg --arch=${ARCH} ${DISTRO} /sysroot ${DEBOOT} && \
        chroot /sysroot sh -c \
            'echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections && \
                apt update && \
                rm -rf /etc/ssl/certs/*.pem && \
                apt install --reinstall -y ssl-cert && \
                apt install --reinstall -y ca-certificates && \
                apt-get install -y \
                    sudo \
                    build-essential \
                    git \
                    libmicrohttpd-dev \
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
                    protobuf-compiler \
                    protobuf-c-compiler \
                    libsensors4-dev \
                    python3 \
                    python3-setuptools \
                    python3-protobuf \
                    python3-pip \
                    python3-simplejson \
                    librtlsdr0 \
                    libusb-1.0-0-dev \
                    libubertooth-dev \
                    libbtbb-dev \
                    libubertooth1 \
                    libbtbb1 \
                ' && \
        cd /sysroot/lib/${ABI} && find ./ -name '*.so*' -lname '/*' -exec sh -c 'export TARGET=$(basename $(readlink $0)); rm $0; ln -snf "$TARGET" "$(basename "$0")";' {} \; 

 RUN cd /tmp && \
         curl -LO ${PB}/v${PBV}/protoc-${PBV}-linux-x86_64.zip && \
         cd /usr/ && \
         unzip /tmp/protoc-${PBV}-linux-x86_64.zip
	

