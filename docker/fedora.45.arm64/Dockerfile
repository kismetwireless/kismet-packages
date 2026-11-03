FROM fedora:45

# Cross compiles with clang against the arm64 sysroot; Fedora's cross gcc has
# no target libc or libstdc++.  protoc comes from the same Fedora release as
# the sysroot's protobuf.

ENV CHECKOUT HEAD NCORES

ENV ARCH arm64
ENV ABI aarch64-redhat-linux

RUN dnf -y install \
        clang \
        lld \
        llvm \
        make \
        git \
        cmake \
        pkgconf-pkg-config \
        protobuf-compiler \
        protobuf-c-compiler \
        glib2-devel \
        ruby \
        ruby-devel \
        gcc \
        rpm-build \
        findutils \
        && \
    dnf clean all && \
    gem install --no-document fpm
