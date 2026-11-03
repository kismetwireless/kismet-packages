#!/bin/bash

# Print the repos to publish, one per line, from the modular platform
# definitions (see platform).  Each platform publishes to its KISMET_REPO, in
# its KISMET_PKG_FORMAT.
#
#   modular_repos.sh [base] [format]
#
# format is deb (the default) or rpm to print the repos of that format, or all
# to print "[format] [repo]" for every repo.

if test $# -lt 1 -o $# -gt 2; then
    echo "Expected [base] [format]" >&2
    exit 1
fi

BASE_DIR=$1
WANT=${2:-deb}

PLATFORMS="${BASE_DIR}/scripts/modular-build/platforms"

if ! test -d "${PLATFORMS}"; then
    echo "*** No modular platforms in ${PLATFORMS} ***" >&2
    exit 1
fi

. "${BASE_DIR}/scripts/host/platform"

for p in "${PLATFORMS}"/*_*; do
    test -f "${p}" || continue

    _PLATFORM_LOAD "${p}"

    if test "${WANT}" = "all"; then
        echo "${PLATFORM_FORMAT} ${PLATFORM_REPO}"
    elif test "${WANT}" = "${PLATFORM_FORMAT}"; then
        echo "${PLATFORM_REPO}"
    fi
done | sort -u
