#!/bin/bash

# Generate the package repos for every modular platform and upload them.
# Each platform publishes its packages to its KISMET_REPO with the publish
# module for its KISMET_PKG_FORMAT, in scripts/host/publish/[format]:
#
#   deb     aptly repos in repos-aptly/apt/[kind]/[repo]
#   rpm     createrepo_c repos in repos-rpm/[kind]/[repo]
#
#   publish_repos.sh [base] git
#   publish_repos.sh [base] release [version]
#
# git publishes the nightly packages.  release publishes the packages for a
# release version; a repo without that version's packages keeps its
# published repo.
#
# Environment:
#   KISMET_CREDS_DIR      signing passphrase and upload ssh config (defaults to
#                         [base]/../kismet-packages-creds)
#   KISMET_SIGNING_KEY    gpg key the repos are signed with (default 8E18F4B6)
#   PUBLISH_UPLOAD        0 to generate the repos without uploading them
#   PUBLISH_RPM_UPLOAD    1 to upload the rpm repos too; off until the repo
#                         server has a place for them
#
# Exit codes:
#   0   every repo was generated and uploaded
#   1   a repo or an upload failed

if test $# -lt 2; then
    echo "Expected [base] git, or [base] release [version]"
    exit 1
fi

BASE_DIR=$(cd "$1" && pwd) || exit 1
KIND=$2
MATCH=""

case "${KIND}" in
    git)
        ;;
    release)
        if test $# -ne 3; then
            echo "Expected [base] release [version]"
            exit 1
        fi

        MATCH=$3
        ;;
    *)
        echo "*** Unknown repo kind ${KIND}; expected git or release ***"
        exit 1
        ;;
esac

export BASE_DIR KIND MATCH
export KISMET_CREDS_DIR="${KISMET_CREDS_DIR:-${BASE_DIR}/../kismet-packages-creds}"
export KISMET_SIGNING_KEY="${KISMET_SIGNING_KEY:-8E18F4B6}"
PUBLISH_UPLOAD="${PUBLISH_UPLOAD:-1}"
PUBLISH_RPM_UPLOAD="${PUBLISH_RPM_UPLOAD:-0}"

. "${BASE_DIR}/scripts/host/platform"
. "${BASE_DIR}/scripts/host/publish/deb"
. "${BASE_DIR}/scripts/host/publish/rpm"

FAILED=0
declare -A PIDS
declare -A FORMATS

# Platforms sharing a repo publish it once
while read -r p; do
    _PLATFORM_LOAD "${p}"

    if test "${FORMATS[${PLATFORM_REPO}]+set}" = "set"; then
        continue
    fi

    FORMATS[${PLATFORM_REPO}]=${PLATFORM_FORMAT}

    case "${PLATFORM_FORMAT}" in
        deb)
            _PUBLISH_DEB_REPO "${PLATFORM_REPO}" &
            ;;
        rpm)
            _PUBLISH_RPM_REPO "${PLATFORM_REPO}" "${PLATFORM_TEST_IMAGE}" &
            ;;
        *)
            echo "*** ${p}: unknown package format ${PLATFORM_FORMAT} ***"
            FAILED=1
            continue
            ;;
    esac

    PIDS[${PLATFORM_REPO}]=$!
done < <(ls -1 "${BASE_DIR}"/scripts/modular-build/platforms/*_*)

for r in "${!PIDS[@]}"; do
    if ! wait ${PIDS[${r}]}; then
        echo "*** Publishing the ${FORMATS[${r}]} ${KIND} repo ${r} FAILED ***"
        FAILED=1
    fi
done

if test "${PUBLISH_UPLOAD}" = "0"; then
    echo "*** Not uploading (PUBLISH_UPLOAD=0) ***"
    exit ${FAILED}
fi

echo "Uploading..."

_UPLOAD_DEB_REPOS || FAILED=1

if test "${PUBLISH_RPM_UPLOAD}" = "1"; then
    _UPLOAD_RPM_REPOS || FAILED=1
else
    echo "*** Not uploading the rpm repos (PUBLISH_RPM_UPLOAD is not 1) ***"
fi

exit ${FAILED}
