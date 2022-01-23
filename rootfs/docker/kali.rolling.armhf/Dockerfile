FROM kalilinux/kali-rolling

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV ARCH armhf
ENV ABI arm-linux-gnueabihf

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
            python3-pip \
            pkg-config \
            make \
            protobuf-c-compiler \
        && \
        gem install --no-document fpm 

RUN curl "https://gitlab.com/kalilinux/packages/debootstrap/raw/kali/master/scripts/kali" > kali-debootstrap && \
        debootstrap --arch=${ARCH} --components=main,contrib,non-free kali-rolling /sysroot https://http.kali.org/kali ./kali-debootstrap && \
        chroot /sysroot sh -c \
            "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
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
                    libncurses5-dev \
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
                " && \
        cd /sysroot/lib/${ABI} && find ./ -name '*.so*' -lname '/*' -exec sh -c 'export TARGET=$(basename $(readlink $0)); rm $0; ln -snf "$TARGET" "$(basename "$0")";' {} \; 

RUN cd /tmp && \
        curl -LO ${PB}/v${PBV}/protoc-${PBV}-linux-x86_64.zip && \
        cd /usr/ && \
        unzip /tmp/protoc-${PBV}-linux-x86_64.zip
	

