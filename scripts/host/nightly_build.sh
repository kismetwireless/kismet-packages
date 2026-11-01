#!/bin/bash 

if test $# -ne 2; then
    echo "Expected [base] [src]"
	exit
fi

export BASE_DIR=$1
export SRC_DIR=$2

if test -e ${BASE_DIR}/pause; then
    echo "Paused"
    exit
fi

. ${BASE_DIR}/scripts/host/buildlog
_BUILDLOG_RUN_START nightly ${SRC_DIR}

${BASE_DIR}/scripts/host/rebuild_all_git.sh $*
${BASE_DIR}/scripts/host/aptly_update_repos.sh $1
PUBLISH_RC=$?

_BUILDLOG_RUN_END ${PUBLISH_RC}
exit ${PUBLISH_RC}

