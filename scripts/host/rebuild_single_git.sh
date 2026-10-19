#!/bin/bash

# Interactively rebuild the nightly git packages for selected docker targets
# with the modular build system, then offer to sync the git repos.
#
# [base] and [src] default to ~/src/kismet-packages and ~/src/kismet.

if test $# -eq 0; then
    BASE_DIR="${HOME}/src/kismet-packages"
    SRC_DIR="${HOME}/src/kismet"
elif test $# -eq 2; then
    BASE_DIR=$1
    SRC_DIR=$2
else
    echo "Expected [base] [src], or no arguments for ~/src/kismet-packages ~/src/kismet"
    exit 1
fi

BASE_DIR=$(cd "${BASE_DIR}" && pwd) || exit 1
SRC_DIR=$(cd "${SRC_DIR}" && pwd) || exit 1
export BASE_DIR SRC_DIR
export NCORES=${NCORES:-$(nproc)}

# Docker targets with a modular platform
TARGETS=()

for d in "${BASE_DIR}"/docker/*; do
    t=$(basename "${d}")

    IFS=. read -r DISTRO RELEASE TARGET_ARCH <<< "${t}"

    if test -f "${BASE_DIR}/scripts/modular-build/platforms/${DISTRO}_${RELEASE}"; then
        TARGETS+=("${t}")
    fi
done

if test ${#TARGETS[@]} -eq 0; then
    echo "*** No docker targets with a modular platform in ${BASE_DIR} ***"
    exit 1
fi

echo "Supported platforms:"
for i in "${!TARGETS[@]}"; do
    IFS=. read -r DISTRO RELEASE TARGET_ARCH <<< "${TARGETS[$i]}"
    printf "  %2d) %-8s %-10s %s\n" $((i + 1)) "${DISTRO}" "${RELEASE}" "${TARGET_ARCH}"
done

echo
echo "Select platforms by number, separated by spaces or commas; ranges such"
echo "as 3-5 are allowed, and 'a' selects every platform."
read -r -p "Platforms to rebuild: " SEL

if test "${SEL}"x = "x"; then
    echo "Nothing selected"
    exit 0
fi

SELECTED=()

if test "${SEL}" = "a" -o "${SEL}" = "A"; then
    SELECTED=("${TARGETS[@]}")
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

echo
echo "Rebuilding: ${SELECTED[*]}"

mkdir -p "${BASE_DIR}/logs"

BUILT=()
FAILED=()

for t in "${SELECTED[@]}"; do
    rm -f "${BASE_DIR}/logs/${t}.last"

    /usr/bin/time "${BASE_DIR}/scripts/host/modular_build_single.sh" "${BASE_DIR}" "${SRC_DIR}" "${t}" 2>&1 | tee "${BASE_DIR}/logs/${t}.last"

    if test ${PIPESTATUS[0]} -eq 0; then
        BUILT+=("${t}")
    else
        FAILED+=("${t}")
    fi
done

echo
echo "*** Rebuild complete ***"
echo "Built:   ${BUILT[*]}"
echo "Failed:  ${FAILED[*]}"

if test ${#FAILED[@]} -eq 0; then
    echo "*** All selected platforms built successfully ***"
else
    echo "*** ${#FAILED[@]} of ${#SELECTED[@]} platforms failed; see ${BASE_DIR}/logs/[target].last ***"
fi

echo
read -r -p "Sync the git package repos now? [y/N] " ANS

if test "${ANS}" = "y" -o "${ANS}" = "Y"; then
    "${BASE_DIR}/scripts/host/aptly_update_repos.sh" "${BASE_DIR}"
fi

if test ${#FAILED[@]} -ne 0; then
    exit 1
fi
