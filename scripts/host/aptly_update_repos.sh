#!/bin/bash

# Generate and upload the nightly git repos for every modular platform; see
# publish_repos.sh.

if test $# -ne 1; then
    echo "Expected [basedir]"
    exit 1
fi

exec "$1/scripts/host/publish_repos.sh" "$1" git
