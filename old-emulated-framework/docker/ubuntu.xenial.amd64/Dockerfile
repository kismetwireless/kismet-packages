FROM ubuntu:xenial

ENV CHECKOUT HEAD NCORES

COPY easy_install /usr/bin/easy_install

RUN apt-get update && apt-get install -y \
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
	libncurses5-dev \
	libnm-dev \
	libdw-dev \
	libsqlite3-dev \
	libprotobuf-dev \
	libprotobuf-c-dev \
	protobuf-compiler \
	protobuf-c-compiler \
	libsensors4-dev \
	python \
	python-setuptools \
	python-protobuf \
	python-pip \
	librtlsdr0 \
	libusb-1.0-0-dev \
	ruby \
	ruby-dev \
	rubygems && \
	gem install --no-ri --no-rdoc fpm

