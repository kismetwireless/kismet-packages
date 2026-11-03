FROM parrotsec/core:latest

# Docker Hub only publishes Parrot 7.x as latest; stop if it moves past echo
RUN . /etc/os-release && test "${VERSION_CODENAME}" = echo || { echo "*** parrotsec/core:latest is ${PRETTY_NAME}, not echo ***"; exit 1; }

# Derive from parrot to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV DISTRO echo

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
        gem install --no-document fpm 

