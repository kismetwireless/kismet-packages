FROM ubuntu:focal

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV DISTRO focal

ENV ARCH arm64
ENV ABI aarch64-linux-gnu

# Prep host
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

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
        gem install dotenv -v 2.8.1 && \
        gem install --no-document fpm 

