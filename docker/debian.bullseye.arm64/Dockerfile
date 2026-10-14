FROM debian:bullseye

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV DISTRO bullseye

ENV ARCH arm64
ENV ABI aarch64-linux-gnu

# Prep host
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Bullseye is end of life; deb.debian.org no longer carries its security
# updates, so install everything from archive.debian.org
RUN sed -i "s|http://deb.debian.org|http://archive.debian.org|g" /etc/apt/sources.list

# Install host deps
RUN apt update && \
        apt install -y \
            debootstrap \
            gcc-${ABI} \
            g++-${ABI} \
            qemu-user-static \
            libglib2.0-dev \
            curl \
            ruby \
            ruby-dev \
            rubygems \
            git \
            python3-setuptools \
            python3-pip \
            pkg-config \
            make \
            cmake \
            protobuf-c-compiler \
            protobuf-compiler \
        && \
        gem install --no-document fpm 

