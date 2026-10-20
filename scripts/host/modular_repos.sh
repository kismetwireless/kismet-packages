#!/bin/bash

# Print the apt repos to publish, one per line, from the modular platform
# definitions.  Platforms are named [distro]_[release] and publish to the
# repo named for the release, except kali_rolling, which publishes to kali.
#
#   modular_repos.sh [base]

if test $# -ne 1; then
    echo "Expected [base]" >&2
    exit 1
fi

PLATFORMS="$1/scripts/modular-build/platforms"

if ! test -d "${PLATFORMS}"; then
    echo "*** No modular platforms in ${PLATFORMS} ***" >&2
    exit 1
fi

for p in "${PLATFORMS}"/*_*; do
    test -f "${p}" || continue

    IFS=_ read -r DISTRO RELEASE <<< "$(basename "${p}")"

    if test "${DISTRO}" = "kali"; then
        echo "kali"
    else
        echo "${RELEASE}"
    fi
done | sort -u
