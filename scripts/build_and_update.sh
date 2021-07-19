#!/bin/bash -e

BASE_DIR=${BASE_DIR:-$1}
SRC_DIR=${SRC_DIR:-$2}
export BASE_DIR
export SRC_DIR

${BASE_DIR}/scripts/rebuild_all_git.sh
${BASE_DIR}/scripts/aptly_update_repos.sh

