#!/bin/bash

# Run the modular nightly (git HEAD) build for one docker target.
#
# Docker targets are named [distro].[release].[arch]; the modular platform
# is [distro]_[release].  amd64 and i386 targets build natively, all other
# arches cross-compile against the target sysroot.
#
# Exit codes:
#   0   built, or no build needed
#   1   build failed
#   2   no modular platform for this target

if test $# -ne 3; then
    echo "Expected [base] [src] [docker]"
    exit 1
fi

export BASE_DIR=$1
export SRC_DIR=$2
TARGET=$(basename "$3")

if test "${NCORES}"x = "x"; then
    export NCORES=$(nproc)
fi

IFS=. read -r DISTRO RELEASE TARGET_ARCH <<< "${TARGET}"
PLATFORM="${DISTRO}_${RELEASE}"

if ! test -d "${BASE_DIR}/docker/${TARGET}"; then
    echo "*** Unknown docker target ${TARGET} ***"
    exit 1
fi

if ! test -f "${BASE_DIR}/scripts/modular-build/platforms/${PLATFORM}"; then
    echo "*** No modular platform ${PLATFORM} for ${TARGET}, skipping ***"
    exit 2
fi

case "${TARGET_ARCH}" in
    amd64|i386)
        CROSS=0
        ;;
    *)
        CROSS=1
        ;;
esac

# Record which packaging scripts built the nightly packages
REF="master"
if git -C "${BASE_DIR}" rev-parse --short HEAD > /dev/null 2>&1; then
    REF="master-$(git -C "${BASE_DIR}" rev-parse --short HEAD)"
fi

echo "*** Modular build ${TARGET}: platform ${PLATFORM} cross ${CROSS} ref ${REF} ***"

cd "${BASE_DIR}/docker/${TARGET}" || exit 1

# Override the compose command so nightly builds use the modular launcher
# regardless of which launcher the target uses for release builds
docker compose run --rm \
    -e NCORES \
    -e CHECKOUT=HEAD \
    -e VERSION= \
    -e BUILD_PLATFORM="${PLATFORM}" \
    -e BUILD_CROSS="${CROSS}" \
    -e MODULAR_BUILD_REF="${REF}" \
    kismet-build /scripts/launch/modular.sh || exit 1
