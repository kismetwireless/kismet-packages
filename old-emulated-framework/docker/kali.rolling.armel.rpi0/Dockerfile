FROM kali-rolling-armel

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

COPY qemu-arm-static /usr/bin/qemu-arm-static
COPY qemu-arm-static /usr/bin/qemu-arm
COPY easy_install /usr/bin/easy_install

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#RUN rm -rf /etc/ssl/certs/*.pem && dpkg -i /root/ca-certificates_*_all.deb && apt update && \
RUN	apt update && \
    rm -rf /etc/ssl/certs/*.pem && \
    apt install --reinstall -y ssl-cert && \
    apt install --reinstall -y ca-certificates && \
	apt-get install -y \
        sudo \
        build-essential \
        git \
        libwebsockets-dev \
        libmicrohttpd-dev \
        pkg-config \
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
        ruby \
        ruby-dev \
        rubygems && \
        gem install --no-document fpm

