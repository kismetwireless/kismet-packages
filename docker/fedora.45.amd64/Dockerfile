FROM fedora:45

ENV CHECKOUT HEAD NCORES

ENV ARCH amd64
ENV ABI x86_64-redhat-linux

RUN dnf -y install \
        gcc-c++ \
        make \
        git \
        cmake \
        pkgconf-pkg-config \
        libwebsockets-devel \
        zlib-ng-compat-devel \
        libnl3-devel \
        libcap-devel \
        libpcap-devel \
        NetworkManager-libnm-devel \
        elfutils-devel \
        sqlite-devel \
        protobuf-devel \
        protobuf-c-devel \
        protobuf-compiler \
        protobuf-c-compiler \
        lm_sensors-devel \
        glib2-devel \
        rtl-sdr-devel \
        libusb1-devel \
        libzstd-devel \
        xz-devel \
        mosquitto-devel \
        pcre2-devel \
        openssl-devel \
        libbtbb-devel \
        ubertooth-devel \
        ruby \
        ruby-devel \
        rpm-build \
        binutils \
        findutils \
        && \
    dnf clean all && \
    gem install --no-document fpm
