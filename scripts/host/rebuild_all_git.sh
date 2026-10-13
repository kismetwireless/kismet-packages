#!/bin/bash

# Build nightly git packages for every docker target with the modular build
# system.  A failed target does not stop the remaining targets; the modular
# build only replaces a target's packages when all of them build.

if test $# -ne 2; then
    echo "Expected [base] [src]"
    exit 1
fi

export BASE_DIR=$1
export SRC_DIR=$2
export NCORES=$(nproc)

mkdir -p ${BASE_DIR}/logs
rm -vf ${BASE_DIR}/logs/*.last

BUILT=()
SKIPPED=()
FAILED=()

for d in ${BASE_DIR}/docker/*; do
    t=$(basename ${d})

    /usr/bin/time ${BASE_DIR}/scripts/host/modular_build_single.sh ${BASE_DIR} ${SRC_DIR} ${t} 2>&1 | tee ${BASE_DIR}/logs/${t}.last

    case ${PIPESTATUS[0]} in
        0)
            BUILT+=(${t})
            ;;
        2)
            SKIPPED+=(${t})
            ;;
        *)
            FAILED+=(${t})
            ;;
    esac
done

echo "*** Nightly build complete ***"
echo "Built:   ${BUILT[*]}"
echo "Skipped: ${SKIPPED[*]}"
echo "Failed:  ${FAILED[*]}"

if test ${#FAILED[@]} -ne 0; then
    exit 1
fi
