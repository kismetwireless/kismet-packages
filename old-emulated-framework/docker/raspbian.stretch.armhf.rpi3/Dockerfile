FROM raspbian/stretch

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

COPY qemu-arm-static /usr/bin/qemu-arm-static
COPY qemu-arm-static /usr/bin/qemu-arm
COPY easy_install /usr/bin/easy_install

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
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
	ruby-dev \ 
	rubygems1.8 && \
	gem install --no-ri --no-rdoc fpm

