#!/bin/bash

# Run the modular build for one docker target.
#
# Nightly (git HEAD) builds use the live scripts in scripts/modular-build,
# and build KISMET_REV when it is set (rebuild_all_git.sh pins it per run).
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
# A target whose build dependencies changed has a docker/[target]/REGENERATE
# marker (see mark_docker_regenerate.sh); its docker image is regenerated
# before building, and the marker removed once that succeeds.
#
# Every build that gets as far as a known target appends a type=target record
# to logs/builds.log (see buildlog); BUILDLOG sets another log file, and
# BUILDLOG_RUN tags the record with a nightly run.  DPKG_DIR overrides the
# package destination inside the container, so a test build can leave its
# packages in the container's /build instead of the published dpkgs.
#
# Exit codes:
#   0   built, or no build needed
#   1   build failed, or regenerating the docker image failed
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

. "${BASE_DIR}/scripts/host/buildlog"

BUILD_START=$(date +%s)
BUILD_OUT=$(mktemp) || exit 1

_BUILDLOG_SET ts "$(date -d @${BUILD_START} -Iseconds)"
_BUILDLOG_SET type target
test "${BUILDLOG_RUN}"x != "x" && _BUILDLOG_SET run "${BUILDLOG_RUN}"
_BUILDLOG_SET target "${TARGET}"
_BUILDLOG_SET status unknown
_BUILDLOG_SET duration_s 0
_BUILDLOG_SET host "$(hostname -s)"
_BUILDLOG_SET ncores "${NCORES}"
_BUILDLOG_SET load1 "$(cut -d ' ' -f 1 /proc/loadavg)"

# Write the target record however the build ends
_BUILD_FINISH() {
    local rc=$? status rev head prev

    _ENERGY_STOP

    case ${rc} in
        0)
            if grep -q "no build required" "${BUILD_OUT}"; then
                status=unchanged
            else
                status=built
            fi
            ;;
        2)
            status=skipped
            ;;
        *)
            status=failed
            ;;
    esac

    _BUILDLOG_SET status ${status}
    _BUILDLOG_SET rc ${rc}
    _BUILDLOG_SET duration_s $(($(date +%s) - BUILD_START))

    _BUILDLOG_ADD_STATS "${BUILD_OUT}"

    # Scripts from older packaging tags don't report the revision they built
    rev=${_BUILDLOG_VALS[kismet_rev]}
    if test "${rev}"x = "x"; then
        rev=$(git -C "${SRC_DIR}" rev-parse --short "${RELEASE_TAG:-${KISMET_REV:-HEAD}}" 2> /dev/null)
        test "${rev}"x != "x" && _BUILDLOG_SET kismet_rev "${rev}"
    fi

    # How far the source moved since this target last built, and how far
    # behind the source tree it is
    prev=$(_BUILDLOG_LAST type=target target=${TARGET} kind=${_BUILDLOG_VALS[kind]} status=built kismet_rev)
    if test "${prev}"x != "x"; then
        _BUILDLOG_SET prev_rev "${prev}"
        _BUILDLOG_GIT_DELTA "${SRC_DIR}" "${prev}" "${rev}"
    fi

    head=$(git -C "${SRC_DIR}" rev-parse --short HEAD 2> /dev/null)
    if test "${head}"x != "x" -a "${rev}"x != "x"; then
        _BUILDLOG_SET head_rev "${head}"
        _BUILDLOG_SET behind "$(git -C "${SRC_DIR}" rev-list --count "${rev}..${head}" 2> /dev/null)"
    fi

    if test ${status} = failed; then
        _BUILDLOG_SET reason "$(grep -a -m 1 -E '\*\*\* .*FAILED|configure: error|[Ee]rror:|Error [0-9]+|Killed signal|No space left|Error response from daemon|failed to solve|Cannot connect to the Docker daemon' "${BUILD_OUT}" | cut -c 1-200)"
    elif test ${status} = skipped; then
        _BUILDLOG_SET reason "no modular platform ${PLATFORM}"
    fi

    _BUILDLOG_WRITE
    rm -f "${BUILD_OUT}"
}

trap _BUILD_FINISH EXIT
_ENERGY_START

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

_BUILDLOG_SET platform "${PLATFORM}"
_BUILDLOG_SET arch "${TARGET_ARCH}"
_BUILDLOG_SET cross ${CROSS}
_BUILDLOG_SET kind "$(test "${RELEASE_TAG}"x != "x" && echo release || echo nightly)"
_BUILDLOG_SET checkout "${CHECKOUT}"
_BUILDLOG_SET packaging "${REF}"
_BUILDLOG_SET regen 0

cd "${BASE_DIR}/docker/${TARGET}" || exit 1

# The target's make container also rebuilds a cross build's sysroot
if test -f REGENERATE; then
    echo "*** Regenerating docker ${TARGET}: ***"
    sed 's/^/    /' REGENERATE

    _BUILDLOG_SET regen 1
    REGEN_START=$(date +%s)

    make container 2>&1 | tee -a "${BUILD_OUT}"
    REGEN_RC=${PIPESTATUS[0]}
    _BUILDLOG_SET regen_s $(($(date +%s) - REGEN_START))

    if test ${REGEN_RC} -ne 0; then
        echo "*** Regenerating docker ${TARGET} failed, leaving its REGENERATE marker ***"
        exit 1
    fi

    rm -f REGENERATE
    echo "*** Regenerated docker ${TARGET} ***"
fi

DPKG_ARGS=()
if test "${DPKG_DIR}"x != "x"; then
    DPKG_ARGS=(-e DPKG_DIR="${DPKG_DIR}")
fi

# Override the compose command so builds use the modular launcher regardless
# of which launcher the target uses for legacy builds
docker compose run --rm \
    "${RELEASE_ARGS[@]}" \
    "${DPKG_ARGS[@]}" \
    -e NCORES \
    -e CHECKOUT="${CHECKOUT}" \
    -e KISMET_REV="${KISMET_REV}" \
    -e VERSION="${VERSION}" \
    -e BUILD_PLATFORM="${PLATFORM}" \
    -e BUILD_CROSS="${CROSS}" \
    -e MODULAR_BUILD_REF="${REF}" \
    kismet-build /scripts/launch/modular.sh 2>&1 | tee -a "${BUILD_OUT}"

test ${PIPESTATUS[0]} -eq 0 || exit 1
