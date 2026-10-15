#!/bin/bash

# Run the modular build for one docker target.
#
# Nightly (git HEAD) builds use the live scripts in scripts/modular-build.
# Release builds are selected by setting, in the environment:
#
#   RELEASE_TAG         kismet git tag to build
#   VERSION             package version for the release
#   MODULAR_SCRIPTS     host directory holding the frozen modular-build
#                       scripts, mounted at /modular-build
#   MODULAR_BUILD_REF   packaging tag recorded in the packages
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

if test "${RELEASE_TAG}"x != "x"; then
    if test "${VERSION}"x = "x" -o "${MODULAR_SCRIPTS}"x = "x" -o "${MODULAR_BUILD_REF}"x = "x"; then
        echo "*** Release builds need VERSION, MODULAR_SCRIPTS, and MODULAR_BUILD_REF ***"
        exit 1
    fi

    SCRIPTS="${MODULAR_SCRIPTS}"
else
    SCRIPTS="${BASE_DIR}/scripts/modular-build"
fi

if ! test -f "${SCRIPTS}/platforms/${PLATFORM}"; then
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

if test "${RELEASE_TAG}"x != "x"; then
    CHECKOUT="${RELEASE_TAG}"
    REF="${MODULAR_BUILD_REF}"
    RELEASE_ARGS=(-v "${MODULAR_SCRIPTS}:/modular-build:ro")
else
    CHECKOUT="HEAD"
    VERSION=""
    RELEASE_ARGS=()

    # Record which packaging scripts built the nightly packages
    REF="master"
    if git -C "${BASE_DIR}" rev-parse --short HEAD > /dev/null 2>&1; then
        REF="master-$(git -C "${BASE_DIR}" rev-parse --short HEAD)"
    fi
fi

echo "*** Modular build ${TARGET}: platform ${PLATFORM} cross ${CROSS} checkout ${CHECKOUT} ref ${REF} ***"

cd "${BASE_DIR}/docker/${TARGET}" || exit 1

# Override the compose command so builds use the modular launcher regardless
# of which launcher the target uses for legacy builds
docker compose run --rm \
    "${RELEASE_ARGS[@]}" \
    -e NCORES \
    -e CHECKOUT="${CHECKOUT}" \
    -e VERSION="${VERSION}" \
    -e BUILD_PLATFORM="${PLATFORM}" \
    -e BUILD_CROSS="${CROSS}" \
    -e MODULAR_BUILD_REF="${REF}" \
    kismet-build /scripts/launch/modular.sh || exit 1
