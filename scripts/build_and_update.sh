#!/bin/bash -e

BASE_DIR=${BASE_DIR:-'.'}
export BASE_DIR

${BASE_DIR}/scripts/rebuild_all_git.sh
${BASE_DIR}/scripts/aptly_update_repos.sh

