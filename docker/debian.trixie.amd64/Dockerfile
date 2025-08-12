FROM debian:trixie

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV ARCH amd64
ENV ABI x86_64-linux-gnu

RUN apt-get update && \
    apt-get install -y \
	    sudo \
	    build-essential \
	    git \
        cmake \
        libwebsockets19t64 \
	    libwebsockets-dev \
	    pkg-config \
        zlib1g \
	    zlib1g-dev \
	    libnl-3-dev \
	    libnl-genl-3-dev \
	    libcap-dev \
	    libpcap-dev \
	    libnm-dev \
	    libdw-dev \
        libsqlite3-0 \
	    libsqlite3-dev \
        libprotobuf32t64 \
	    libprotobuf-dev \
        libprotobuf-c1 \
	    libprotobuf-c-dev \
	    protobuf-compiler \
	    protobuf-c-compiler \
        libsensors5 \
	    libsensors-dev \
	    libglib2.0-dev \
	    librtlsdr0 \
        librtlsdr-dev \
        libusb-1.0-0 \
	    libusb-1.0-0-dev \
        libmosquitto1 \
        libmosquitto-dev \
        libubertooth1 \
        libubertooth-dev \
        libbtbb1 \
        libbtbb-dev \
	    ruby \
	    ruby-dev \
	    rubygems && \
	    gem install --no-document fpm

	    #python3 \
	    #python3-setuptools \
	    #python3-protobuf \
	    #python3-pip \
	    #python3-simplejson \
