#!/bin/bash

if test $# -ne 5; then
    echo "Expected [base] [src] [docker] [distro] [platform]"
	exit 1
fi

# distro and platform are derived from the docker target name by the modular
# build; they are accepted for compatibility

exec $1/scripts/host/modular_build_single.sh $1 $2 $3
