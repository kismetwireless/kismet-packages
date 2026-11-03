#!/bin/bash

# Generate and upload the release repos for a version for every modular
# platform; see publish_repos.sh.

if test $# -ne 2; then
    echo "Expected [basedir] [version]"
    exit 1
fi

exec "$1/scripts/host/publish_repos.sh" "$1" release "$2"
