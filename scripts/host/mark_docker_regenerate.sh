#!/bin/bash

# Mark docker targets as needing their images regenerated, such as after
# adding build dependencies to their Dockerfiles.  The modular build
# regenerates a marked target before building it and then removes the marker.
#
#   mark_docker_regenerate.sh [base] "reason" [target...]
#
# With no targets, every docker target is marked.

if test $# -lt 2; then
    echo "Expected [base] \"reason\" [target...]"
    exit 1
fi

BASE_DIR=$1
REASON=$2
shift 2

if test $# -eq 0; then
    TARGETS=("${BASE_DIR}"/docker/*/)
else
    TARGETS=()
    for t in "$@"; do
        TARGETS+=("${BASE_DIR}/docker/$(basename "${t}")/")
    done
fi

for d in "${TARGETS[@]}"; do
    if ! test -f "${d}/docker-compose.yaml"; then
        echo "*** Unknown docker target $(basename "${d}") ***"
        exit 1
    fi
done

for d in "${TARGETS[@]}"; do
    echo "$(date -u +%Y-%m-%d) ${REASON}" >> "${d}/REGENERATE"
    echo "Marked $(basename "${d}")"
done
