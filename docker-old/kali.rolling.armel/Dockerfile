FROM kalilinux/kali-rolling

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV ARCH armel
ENV ABI arm-linux-gnueabi

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
            libglib2.0-dev \
            python3-setuptools \
            python3-pip \
            pkg-config \
            make \
            protobuf-compiler \
            protobuf-c-compiler \
        && \
        gem install --no-document fpm 

RUN curl "https://gitlab.com/kalilinux/packages/debootstrap/raw/kali/master/scripts/kali" > kali-debootstrap && \
        debootstrap --arch=${ARCH} --components=main,contrib,non-free kali-rolling /sysroot https://http.kali.org/kali ./kali-debootstrap && \
        chroot /sysroot sh -c \
            "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
                apt update && \
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
                    libprotobuf32t64 \
                    libprotobuf-dev \
                    libprotobuf-c-dev \
                    libsensors-dev \
                    librtlsdr0 \
                    librtlsdr-dev \
                    libusb-1.0-0-dev \
                    libubertooth-dev \
                    libbtbb-dev \
                    libbladerf2 \
                    libbladerf-dev \
                    libpcre2-dev \
                    libmosquitto-dev \
                    " && \
        cd /sysroot/lib/${ABI} && find ./ -name '*.so*' -lname '/*' -exec sh -c 'export TARGET=$(basename $(readlink $0)); rm $0; ln -snf "$TARGET" "$(basename "$0")";' {} \; 

# RUN cd /tmp && \
#         curl -LO ${PB}/v${PBV}/protoc-${PBV}-linux-x86_64.zip && \
#         cd /usr/ && \
#         unzip /tmp/protoc-${PBV}-linux-x86_64.zip
	

