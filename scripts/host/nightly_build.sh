#!/bin/bash -e

BASE_DIR=${BASE_DIR:-$1}
SRC_DIR=${SRC_DIR:-$2}
export BASE_DIR
export SRC_DIR

${BASE_DIR}/scripts/host/rebuild_all_git.sh $*
${BASE_DIR}/scripts/host/aptly_update_repos.sh

