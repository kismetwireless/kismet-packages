FROM debian:bookworm

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
	    libglib2.0-dev \
	    python3 \
	    python3-setuptools \
	    python3-protobuf \
	    python3-pip \
	    python3-simplejson \
	    librtlsdr0 \
        librtlsdr-dev \
	    libusb-1.0-0-dev \
        libmosquitto-dev \
	    ruby \
	    ruby-dev \
	    rubygems && \
	    gem install --no-document fpm

