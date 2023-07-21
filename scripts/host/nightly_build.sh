#!/bin/bash 

if test $# -ne 2; then
    echo "Expected [base] [src]"
	exit
fi

export BASE_DIR=$1
export SRC_DIR=$2

${BASE_DIR}/scripts/host/rebuild_all_git.sh $*
${BASE_DIR}/scripts/host/aptly_update_repos.sh $1

