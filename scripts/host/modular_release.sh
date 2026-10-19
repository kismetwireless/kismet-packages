#!/bin/bash

# Build release packages for a tagged kismet release with the modular build
# system.
#
# Offers the 5 most recent kismet-YYYY-MM-* release tags, checks the dpkgs-*
# directories for the targets which already have packages for the chosen
# release, and builds the missing targets or all of them.
#
# Release builds use the modular scripts from the kismet-packages tag
# modular-[release tag] when it exists.  Otherwise they use the modular
# scripts committed at HEAD, and when every target builds, HEAD is tagged
# modular-[release tag] so later rebuilds of the release use the same
# scripts.  Tags are only created locally; they are never pushed.

_USAGE() {
    cat << EOF
Usage: $(basename "$0") [options] [base] [src]

Build release packages for a tagged kismet release.

  base          kismet-packages directory
  src           kismet source repository, with the release tags

Options:
  --dry-run     show the release, scripts, and targets which would be built,
                and the tag which would be created, without building or
                tagging anything
  --help        show this help
EOF
}

DRY_RUN=0
ARGS=()

for a in "$@"; do
    case "${a}" in
        --dry-run)
            DRY_RUN=1
            ;;
        --help|-h)
            _USAGE
            exit 0
            ;;
        -*)
            echo "*** Unknown option ${a} ***"
            _USAGE
            exit 1
            ;;
        *)
            ARGS+=("${a}")
            ;;
    esac
done

set -- "${ARGS[@]}"

if test $# -ne 2; then
    _USAGE
    exit 1
fi

BASE_DIR=$(cd "$1" && pwd) || exit 1
SRC_DIR=$(cd "$2" && pwd) || exit 1
export BASE_DIR SRC_DIR
export NCORES=${NCORES:-$(nproc)}

RELEASES=($(git -C "${SRC_DIR}" tag -l 'kismet-[0-9][0-9][0-9][0-9]-[0-9][0-9]-*' --sort=-v:refname | head -n 5))

if test ${#RELEASES[@]} -eq 0; then
    echo "*** No kismet-YYYY-MM-* release tags in ${SRC_DIR} ***"
    exit 1
fi

echo "Recent kismet releases:"
for i in "${!RELEASES[@]}"; do
    echo "  $((i + 1))) ${RELEASES[$i]}"
done

read -r -p "Release to build [1]: " SEL
SEL=${SEL:-1}

if ! [[ "${SEL}" =~ ^[0-9]+$ ]] || test "${SEL}" -lt 1 -o "${SEL}" -gt ${#RELEASES[@]}; then
    echo "*** Invalid selection ${SEL} ***"
    exit 1
fi

export RELEASE_TAG=${RELEASES[$((SEL - 1))]}
export VERSION=${RELEASE_TAG#kismet-}
MODULAR_TAG="modular-${RELEASE_TAG}"

# Pick the modular scripts for this release
if git -C "${BASE_DIR}" rev-parse -q --verify "refs/tags/${MODULAR_TAG}" > /dev/null; then
    SCRIPTS_COMMIT=$(git -C "${BASE_DIR}" rev-parse "${MODULAR_TAG}^{commit}")
    export MODULAR_BUILD_REF="${MODULAR_TAG}"
    CREATE_TAG=0

    echo "*** Using modular scripts from tag ${MODULAR_TAG} ***"
else
    SCRIPTS_COMMIT=$(git -C "${BASE_DIR}" rev-parse HEAD) || exit 1
    export MODULAR_BUILD_REF="master-$(git -C "${BASE_DIR}" rev-parse --short HEAD)"
    CREATE_TAG=1

    echo "*** No tag ${MODULAR_TAG}; using modular scripts from HEAD ${SCRIPTS_COMMIT:0:7} ***"

    if test -n "$(git -C "${BASE_DIR}" status --porcelain -- scripts/modular-build)"; then
        echo "*** scripts/modular-build has uncommitted changes, which will not be used ***"
        read -r -p "Continue? [y/N] " ANS

        if test "${ANS}" != "y" -a "${ANS}" != "Y"; then
            exit 1
        fi
    fi
fi

if ! git -C "${BASE_DIR}" cat-file -e "${SCRIPTS_COMMIT}:scripts/modular-build/modular-build" 2> /dev/null; then
    echo "*** ${SCRIPTS_COMMIT:0:7} has no modular build scripts ***"
    exit 1
fi

# Extract the frozen scripts to mount into the build containers
SCRIPTS_TMP=$(mktemp -d "${TMPDIR:-/tmp}/kismet-modular-release.XXXXXX") || exit 1
trap 'rm -rf "${SCRIPTS_TMP}"' EXIT

git -C "${BASE_DIR}" archive "${SCRIPTS_COMMIT}" scripts/modular-build | tar -x -C "${SCRIPTS_TMP}" || exit 1
export MODULAR_SCRIPTS="${SCRIPTS_TMP}/scripts/modular-build"

# Find which targets already have packages for this release; every platform
# builds the kismet metapackage, and the modular build only installs a
# target's packages when all of them build
BUILT=()
MISSING=()

echo
echo "Release ${VERSION} packages:"

for d in "${BASE_DIR}"/docker/*; do
    t=$(basename "${d}")

    IFS=. read -r DISTRO RELEASE TARGET_ARCH <<< "${t}"

    if ! test -f "${MODULAR_SCRIPTS}/platforms/${DISTRO}_${RELEASE}"; then
        printf "  %-28s no modular platform\n" "${t}"
        continue
    fi

    DPKGS=$(grep -oE 'dpkgs-[A-Za-z0-9_-]+:/dpkgs' "${d}/docker-compose.yaml" | head -n 1)
    DPKGS=${DPKGS%:/dpkgs}
    ARCH=$(grep -oE 'ARCH=[A-Za-z0-9_]+' "${d}/docker-compose.yaml" | head -n 1)
    ARCH=${ARCH#ARCH=}

    if test "${DPKGS}"x = "x" -o "${ARCH}"x = "x"; then
        printf "  %-28s could not find dpkgs dir or arch\n" "${t}"
        continue
    fi

    if test -f "${BASE_DIR}/${DPKGS}/kismet_${VERSION}_${ARCH}.deb"; then
        printf "  %-28s built\n" "${t}"
        BUILT+=("${t}")
    else
        printf "  %-28s missing\n" "${t}"
        MISSING+=("${t}")
    fi
done

echo

if test ${#MISSING[@]} -eq 0; then
    read -r -p "All targets are built; [a]ll rebuild, [q]uit [q]: " ANS
    ANS=${ANS:-q}
else
    read -r -p "Build [m]issing (${#MISSING[@]}), [a]ll ($((${#MISSING[@]} + ${#BUILT[@]}))), [q]uit [m]: " ANS
    ANS=${ANS:-m}
fi

case "${ANS}" in
    m|M)
        TARGETS=("${MISSING[@]}")
        ;;
    a|A)
        TARGETS=("${MISSING[@]}" "${BUILT[@]}")
        ;;
    *)
        exit 0
        ;;
esac

if test ${#TARGETS[@]} -eq 0; then
    exit 0
fi

if test "${DRY_RUN}" = 1; then
    echo
    echo "*** Dry run; nothing will be built or tagged ***"
    echo "Release:   ${RELEASE_TAG} (version ${VERSION})"
    echo "Scripts:   ${SCRIPTS_COMMIT:0:7} (packaging ref ${MODULAR_BUILD_REF})"
    echo "Targets:   ${TARGETS[*]}"

    if test "${CREATE_TAG}" = 1; then
        echo "Tag:       ${MODULAR_TAG} on ${SCRIPTS_COMMIT:0:7}, if every target builds"
    else
        echo "Tag:       ${MODULAR_TAG} already exists"
    fi

    exit 0
fi

mkdir -p "${BASE_DIR}/logs"

DONE=()
FAILED=()

for t in "${TARGETS[@]}"; do
    /usr/bin/time "${BASE_DIR}/scripts/host/modular_build_single.sh" "${BASE_DIR}" "${SRC_DIR}" "${t}" 2>&1 | tee "${BASE_DIR}/logs/${t}.release.last"

    if test ${PIPESTATUS[0]} -eq 0; then
        DONE+=("${t}")
    else
        FAILED+=("${t}")
    fi
done

echo "*** Release ${VERSION} build complete ***"
echo "Built:   ${DONE[*]}"
echo "Failed:  ${FAILED[*]}"

if test ${#FAILED[@]} -ne 0; then
    if test "${CREATE_TAG}" = 1; then
        echo "*** Not tagging ${MODULAR_TAG} because builds failed ***"
    fi

    exit 1
fi

if test "${CREATE_TAG}" = 1; then
    git -C "${BASE_DIR}" tag -a "${MODULAR_TAG}" "${SCRIPTS_COMMIT}" \
        -m "Modular build scripts for kismet release ${RELEASE_TAG}" || exit 1

    echo "*** Tagged ${SCRIPTS_COMMIT:0:7} as ${MODULAR_TAG}; the tag has not been pushed ***"
fi
