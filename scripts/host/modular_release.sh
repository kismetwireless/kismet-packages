#!/bin/bash

# Interactively build release packages for a tagged kismet release with the
# modular build system, then offer to generate and sync the release repos.
#
# Fetches the release tags, offers the 5 most recent kismet-YYYY-MM-* tags
# (the latest by default), and shows each release repo's aptly config and the
# release it publishes now.  Each target shows whether it already has packages
# for the chosen release; build the missing targets or pick them like
# rebuild_single_git.sh.
#
# Release builds use the modular scripts from the kismet-packages tag
# modular-[release tag] when it exists.  Otherwise they use the modular
# scripts committed at HEAD, and when every target builds, HEAD is tagged
# modular-[release tag] so later rebuilds of the release use the same
# scripts.  Tags are only created locally; they are never pushed.
#
# [base] and [src] default to ~/src/kismet-packages and ~/src/kismet.

_USAGE() {
    cat << EOF
Usage: $(basename "$0") [options] [base src]

Build release packages for a tagged kismet release.

  base          kismet-packages directory (default ~/src/kismet-packages)
  src           kismet source repository, with the release tags
                (default ~/src/kismet)

Options:
  --dry-run     show the release, scripts, and targets which would be built,
                and the tag which would be created, without building, tagging
                or publishing anything
  --no-fetch    don't fetch release tags from the kismet origin first
  --help        show this help
EOF
}

DRY_RUN=0
FETCH=1
ARGS=()

for a in "$@"; do
    case "${a}" in
        --dry-run)
            DRY_RUN=1
            ;;
        --no-fetch)
            FETCH=0
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

if test $# -eq 0; then
    BASE_DIR="${HOME}/src/kismet-packages"
    SRC_DIR="${HOME}/src/kismet"
elif test $# -eq 2; then
    BASE_DIR=$1
    SRC_DIR=$2
else
    _USAGE
    exit 1
fi

BASE_DIR=$(cd "${BASE_DIR}" && pwd) || exit 1
SRC_DIR=$(cd "${SRC_DIR}" && pwd) || exit 1
export BASE_DIR SRC_DIR
export NCORES=${NCORES:-$(nproc)}

# _DURATION [seconds]
_DURATION() {
    printf '%d:%02d:%02d' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60))
}

if test "${FETCH}" = 1; then
    echo "*** Fetching release tags from the kismet origin ***"

    if ! git -C "${SRC_DIR}" fetch --tags origin; then
        echo "*** Could not fetch tags; using the tags already in ${SRC_DIR} ***"
    fi
fi

RELEASES=($(git -C "${SRC_DIR}" tag -l 'kismet-[0-9][0-9][0-9][0-9]-[0-9][0-9]-*' --sort=-v:refname | head -n 5))

if test ${#RELEASES[@]} -eq 0; then
    echo "*** No kismet-YYYY-MM-* release tags in ${SRC_DIR} ***"
    exit 1
fi

# The release each repo publishes now, from its published kismet packages
echo
echo "Release repos:"

REPOS=$("${BASE_DIR}/scripts/host/modular_repos.sh" "${BASE_DIR}") || exit 1
MISSING_CONF=()

for dist in ${REPOS}; do
    if ! test -f "${BASE_DIR}/aptly/${dist}-release-aptly.conf"; then
        printf "  %-10s no aptly config aptly/%s-release-aptly.conf\n" "${dist}" "${dist}"
        MISSING_CONF+=("${dist}")
        continue
    fi

    PUBLISHED=$(ls -1 "${BASE_DIR}/repos-aptly/apt/release/${dist}/pool/main/k/kismet/" 2> /dev/null | \
        sed -nE 's/^kismet_(.+)_[a-z0-9]+\.deb$/\1/p' | sort -u -V | tail -n 1)

    printf "  %-10s publishes %s\n" "${dist}" "${PUBLISHED:-nothing yet}"
done

if test ${#MISSING_CONF[@]} -ne 0; then
    echo "*** ${MISSING_CONF[*]} will not be published without a release aptly config ***"
fi

echo
echo "Recent kismet releases:"
for i in "${!RELEASES[@]}"; do
    if test ${i} -eq 0; then
        echo "  $((i + 1))) ${RELEASES[$i]} (latest)"
    else
        echo "  $((i + 1))) ${RELEASES[$i]}"
    fi
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
TARGETS=()
STATE=()
MISSING=()

for d in "${BASE_DIR}"/docker/*; do
    t=$(basename "${d}")

    IFS=. read -r DISTRO RELEASE TARGET_ARCH <<< "${t}"

    if ! test -f "${MODULAR_SCRIPTS}/platforms/${DISTRO}_${RELEASE}"; then
        continue
    fi

    DPKGS=$(grep -oE 'dpkgs-[A-Za-z0-9_-]+:/dpkgs' "${d}/docker-compose.yaml" | head -n 1)
    DPKGS=${DPKGS%:/dpkgs}
    ARCH=$(grep -oE 'ARCH=[A-Za-z0-9_]+' "${d}/docker-compose.yaml" | head -n 1)
    ARCH=${ARCH#ARCH=}

    if test "${DPKGS}"x = "x" -o "${ARCH}"x = "x"; then
        echo "*** ${t}: could not find its dpkgs dir or arch, skipping ***"
        continue
    fi

    TARGETS+=("${t}")

    if test -f "${BASE_DIR}/${DPKGS}/kismet_${VERSION}_${ARCH}.deb"; then
        STATE+=("built")
    else
        STATE+=("missing")
        MISSING+=("${t}")
    fi
done

if test ${#TARGETS[@]} -eq 0; then
    echo "*** No docker targets with a modular platform in ${BASE_DIR} ***"
    exit 1
fi

echo
echo "Release ${VERSION} platforms:"
for i in "${!TARGETS[@]}"; do
    IFS=. read -r DISTRO RELEASE TARGET_ARCH <<< "${TARGETS[$i]}"
    printf "  %2d) %-8s %-10s %-6s %s\n" $((i + 1)) "${DISTRO}" "${RELEASE}" "${TARGET_ARCH}" "${STATE[$i]}"
done

echo
echo "Select platforms by number, separated by spaces or commas; ranges such"
echo "as 3-5 are allowed, 'm' selects the missing platforms and 'a' every platform."

if test ${#MISSING[@]} -eq 0; then
    read -r -p "Platforms to build (all are built): " SEL
else
    read -r -p "Platforms to build [m]: " SEL
    SEL=${SEL:-m}
fi

if test "${SEL}"x = "x"; then
    echo "Nothing selected"
    exit 0
fi

SELECTED=()

if test "${SEL}" = "a" -o "${SEL}" = "A"; then
    SELECTED=("${TARGETS[@]}")
elif test "${SEL}" = "m" -o "${SEL}" = "M"; then
    SELECTED=("${MISSING[@]}")
else
    CHOSEN=()

    for s in ${SEL//,/ }; do
        if [[ "${s}" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            FIRST=${BASH_REMATCH[1]}
            LAST=${BASH_REMATCH[2]}
        elif [[ "${s}" =~ ^[0-9]+$ ]]; then
            FIRST=${s}
            LAST=${s}
        else
            echo "*** Invalid selection ${s} ***"
            exit 1
        fi

        if test "${FIRST}" -lt 1 -o "${LAST}" -gt ${#TARGETS[@]} -o "${FIRST}" -gt "${LAST}"; then
            echo "*** Selection ${s} is not between 1 and ${#TARGETS[@]} ***"
            exit 1
        fi

        for n in $(seq "${FIRST}" "${LAST}"); do
            CHOSEN[${n}]=1
        done
    done

    # Build in the listed order
    for i in "${!TARGETS[@]}"; do
        if test "${CHOSEN[$((i + 1))]}" = 1; then
            SELECTED+=("${TARGETS[$i]}")
        fi
    done
fi

if test ${#SELECTED[@]} -eq 0; then
    echo "Nothing selected"
    exit 0
fi

if test "${DRY_RUN}" = 1; then
    echo
    echo "*** Dry run; nothing will be built, tagged or published ***"
    echo "Release:   ${RELEASE_TAG} (version ${VERSION})"
    echo "Scripts:   ${SCRIPTS_COMMIT:0:7} (packaging ref ${MODULAR_BUILD_REF})"
    echo "Targets:   ${SELECTED[*]}"

    if test "${CREATE_TAG}" = 1; then
        echo "Tag:       ${MODULAR_TAG} on ${SCRIPTS_COMMIT:0:7}, if every target builds"
    else
        echo "Tag:       ${MODULAR_TAG} already exists"
    fi

    echo "Repos:     ${REPOS//$'\n'/ }"
    exit 0
fi

echo
echo "Building ${VERSION}: ${SELECTED[*]}"

mkdir -p "${BASE_DIR}/logs"

DONE=()
FAILED=()
RUN_START=$(date +%s)
N=0

for t in "${SELECTED[@]}"; do
    N=$((N + 1))
    echo
    echo "*** [${N}/${#SELECTED[@]}] $(date '+%H:%M:%S') building ${t} ***"

    START=$(date +%s)
    "${BASE_DIR}/scripts/host/modular_build_single.sh" "${BASE_DIR}" "${SRC_DIR}" "${t}" 2>&1 | tee "${BASE_DIR}/logs/${t}.release.last"
    RC=${PIPESTATUS[0]}
    ELAPSED=$(_DURATION $(($(date +%s) - START)))

    if test ${RC} -eq 0; then
        DONE+=("${t}")
        echo "*** [${N}/${#SELECTED[@]}] $(date '+%H:%M:%S') ${t} built (${ELAPSED}) ***"
    else
        FAILED+=("${t}")
        echo "*** [${N}/${#SELECTED[@]}] $(date '+%H:%M:%S') ${t} FAILED (${ELAPSED}); see ${BASE_DIR}/logs/${t}.release.last ***"
    fi
done

echo
echo "*** Release ${VERSION} build complete ($(_DURATION $(($(date +%s) - RUN_START)))) ***"
echo "Built:   ${DONE[*]}"
echo "Failed:  ${FAILED[*]}"

if test ${#FAILED[@]} -eq 0; then
    echo "*** All selected platforms built successfully ***"

    if test "${CREATE_TAG}" = 1; then
        git -C "${BASE_DIR}" tag -a "${MODULAR_TAG}" "${SCRIPTS_COMMIT}" \
            -m "Modular build scripts for kismet release ${RELEASE_TAG}" || exit 1

        echo "*** Tagged ${SCRIPTS_COMMIT:0:7} as ${MODULAR_TAG}; the tag has not been pushed ***"
    fi
else
    echo "*** ${#FAILED[@]} of ${#SELECTED[@]} platforms failed; see ${BASE_DIR}/logs/[target].release.last ***"

    if test "${CREATE_TAG}" = 1; then
        echo "*** Not tagging ${MODULAR_TAG} because builds failed ***"
    fi
fi

echo
if test ${#FAILED[@]} -ne 0; then
    echo "*** Publishing now would leave the failed platforms' repos without ${VERSION} ***"
fi

read -r -p "Generate and sync the release repos for ${VERSION} now? [y/N] " ANS

if test "${ANS}" = "y" -o "${ANS}" = "Y"; then
    "${BASE_DIR}/scripts/host/aptly_update_release_repos.sh" "${BASE_DIR}" "${VERSION}"
fi

if test ${#FAILED[@]} -ne 0; then
    exit 1
fi
