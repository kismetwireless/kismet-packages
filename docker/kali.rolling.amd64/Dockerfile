FROM kalilinux/kali-rolling

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV ARCH amd64
ENV ABI x86_64-linux-gnu

#ENV PB https://github.com/protocolbuffers/protobuf/releases/download/
#ENV PBV 3.12.4

RUN apt-get update && apt-get install -y \
	sudo \
	build-essential \
	git \
    libwebsockets-dev \
	pkg-config \
    libglib2.0-dev \
	zlib1g-dev \
	libnl-3-dev \
	libnl-genl-3-dev \
	libcap-dev \
	libpcap-dev \
    libpcre2-dev \
	libncurses5-dev \
	libnm-dev \
	libdw-dev \
	libsqlite3-dev \
    libprotobuf32 \
	libprotobuf-dev \
	libprotobuf-c-dev \
	protobuf-compiler \
	protobuf-c-compiler \
	libsensors-dev \
	python3 \
	python3-setuptools \
	python3-protobuf \
	python3-pip \
    python3-simplejson \
	librtlsdr0 \
	libusb-1.0-0-dev \
    libubertooth-dev \
    libbtbb-dev \
    libbladerf2 \
    libbladerf-dev \
    libmosquitto-dev \
    cmake \
	ruby \
	ruby-dev \
	rubygems && \
	gem install --no-document fpm

