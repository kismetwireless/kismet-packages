# Kismet Packaging

Packaging scripts, makefiles, and configurations for building Kismet packages on various platforms.

Separated from the main Kismet repository to simplify version control between Kismet releases and the related package scripts for generating binaries.

## Kismet nightly and release packaging

The Kismet nightly and release packages hosted on the Kismet site are built using the contents of the `docker/` and `scripts/` directories.

## Build docker images

The Kismet builds use docker to isolate the different distribution environments.  

For Intel i386 and x86_64, the native Intel containers are used for building.

For armel and armhf (arm32 pi0 and other pi hardware, respectively), an Intel docker container of the matching distribution and release is created with the cross-compilation toolchain for arm32, and a cross-compile sysroot is created inside the container via debootstrap, chroot+qemu-static+deb to install the remaining packages, and manual scripting to fix symbolic links.

For arm64, a bug in qemu-aarch64 causes segfaults in python3 when running in a chroot (inside a docker or outside), so more extreme measures are required.  For arm64, an arm64 docker of the distribution is created, and the required packages are installed.  Then a docker volume is created, and the filesystem is cloned to a docker volume using `tar ch` to rewrite the broken symlinks and make a sysroot-capable volume.  Finally, an Intel docker of the matching distribution and release is created, the crossbuild toolchain installed, and the sysroot volume mapped into the build docker.

## Building your own packages

You can build your own packages (hopefully easily) using the included scripts.  You will need a Linux system with docker.io, qemu-user-static, and binfmt support (Kismet is build on an Ubuntu server, others should work but are untested.)

1. Define the location of your checkout:

    ```bash
    $ export BASE_DIR=/path/to/kismet-packaging
    ```

2. Define the location of your Kismet checkout; to avoid pulling the entire Kismet repo for every build, the scripts use a local checked out copy of Kismet.

    ```bash
    $ export SRC_DIR=/path/to/kismet/src
    ```

3. Create the docker container for the distro you're building for

    ```bash
    $ cd docker/distro_and_platform_you_want
    $ make container
    ```

    Depending on the platform this may take a bunch of steps - there is a bug in qemu-user-aarch64 for arm64 for instance that makes python3 segfault, making building the crossbuild sysroot quite a pain.

4. Build kismet via the docker image.  While still in the docker directory,

    ```bash
    $ make kismet
    ```
