#!/bin/bash

# Install a target's newly built packages in a clean container of the target
# distribution and architecture, and check that they work there: every
# package installs with its dependencies from the distribution, kismet runs,
# and every installed binary finds the libraries it links against.  Other
# architectures run under qemu.
#
#   install_test.sh [image] [deb|rpm] [docker target arch] [package dir]
#
# Exit codes:
#   0   passed
#   1   failed

if test $# -ne 4; then
    echo "Expected [image] [format] [arch] [package dir]"
    exit 1
fi

IMAGE=$1
FORMAT=$2
TARGET_ARCH=$3
PKG_DIR=$(cd "$4" && pwd) || exit 1

INSTALL_TEST_TIMEOUT=${INSTALL_TEST_TIMEOUT:-1800}

case "${TARGET_ARCH}" in
    amd64)
        DOCKER_PLATFORM=linux/amd64
        ;;
    arm64)
        DOCKER_PLATFORM=linux/arm64
        ;;
    armhf)
        DOCKER_PLATFORM=linux/arm/v7
        ;;
    i386)
        DOCKER_PLATFORM=linux/386
        ;;
    *)
        echo "*** No docker platform for ${TARGET_ARCH} ***"
        exit 1
        ;;
esac

case "${FORMAT}" in
    deb)
        INSTALL='export DEBIAN_FRONTEND=noninteractive
apt-get update -q || exit 1
apt-get install -y -q --no-install-recommends /pkgs/*.deb || exit 1'
        ;;
    rpm)
        INSTALL='dnf -y -q install --setopt=install_weak_deps=False /pkgs/*.rpm || exit 1'
        ;;
    *)
        echo "*** Unknown package format ${FORMAT} ***"
        exit 1
        ;;
esac

if ! compgen -G "${PKG_DIR}/*.${FORMAT}" > /dev/null; then
    echo "*** No ${FORMAT} packages in ${PKG_DIR} ***"
    exit 1
fi

# Pulling a multi-arch tag for another platform retags it, so run the image
# by the id the pull resolved to
docker pull -q --platform "${DOCKER_PLATFORM}" "${IMAGE}" > /dev/null || { echo "*** Pulling ${IMAGE} for ${DOCKER_PLATFORM} failed ***"; exit 1; }
IMAGE_ID=$(docker image inspect --format '{{.Id}}' "${IMAGE}") || exit 1

echo "*** Install test: $(ls "${PKG_DIR}"/*.${FORMAT} | wc -l) packages in ${IMAGE} ${DOCKER_PLATFORM} ***"

timeout "${INSTALL_TEST_TIMEOUT}" docker run --rm -i \
    --platform "${DOCKER_PLATFORM}" \
    -v "${PKG_DIR}:/pkgs:ro" \
    "${IMAGE_ID}" /bin/sh -s << EOF
${INSTALL}

FAILED=0

# kismet --version exits non-zero, so look for the version banner instead
VERSION_OUT=\$(kismet --version 2>&1)
echo "\${VERSION_OUT}"

case "\${VERSION_OUT}" in
    Kismet*)
        ;;
    *)
        echo "*** kismet --version did not run ***"
        FAILED=1
        ;;
esac

for b in /usr/bin/kismet*; do
    if head -c 4 "\$b" | grep -q ELF; then
        MISSING=\$(ldd "\$b" 2>&1 | grep 'not found')

        if test "\${MISSING}"x != "x"; then
            echo "*** \$b: \${MISSING} ***"
            FAILED=1
        fi
    fi
done

if ! getent group kismet > /dev/null; then
    echo "*** The kismet group was not created ***"
    FAILED=1
fi

exit \${FAILED}
EOF
RC=$?

if test ${RC} -ne 0; then
    echo "*** INSTALL TEST FAILED ${IMAGE} ${DOCKER_PLATFORM} (${RC}) ***"
    exit 1
fi

echo "*** Install test passed ***"
exit 0
