FROM ubuntu:jammy

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV CHECKOUT HEAD NCORES

ENV ARCH amd64
ENV ABI x86_64-linux-gnu

RUN apt-get update && apt-get install -y \
	sudo \
	build-essential \
    cmake \
	git \
    libwebsockets-dev \
	pkg-config \
	zlib1g-dev \
    libglib2.0-dev \
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
    libbladerf2 \
    libbladerf-dev \
    libmosquitto-dev \
	ruby \
	ruby-dev \
	rubygems && \
	gem install --no-document fpm

