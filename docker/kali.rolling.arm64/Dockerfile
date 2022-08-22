FROM kalilinux/kali-rolling

# Derive from kali to get the matching gcc attributes

ENV CHECKOUT HEAD NCORES

ENV DEBIAN_FRONTEND noninteractive
ENV TERMINAL linux

ENV DISTRO impish

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
            curl \
            ruby \
            ruby-dev \
            rubygems \
            git \
            libglib2.0-dev \
            python3-setuptools \
            python3-pip \
            pkg-config \
            make \
            cmake \
            protobuf-c-compiler \
            protobuf-compiler \
        && \
        gem install --no-document fpm 

# cd /sysroot/lib/${ABI} && find ./ -name '*.so*' -lname '/*' -exec sh -c 'export TARGET=$(basename $(readlink $0)); rm $0; ln -snf "$TARGET" "$(basename "$0")";' {} \; 

