#!/bin/bash -e

for x in docker/*; do
    pushd "$x"
    docker-compose build --no-cache
    popd
done
