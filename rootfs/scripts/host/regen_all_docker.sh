#!/bin/bash -e

for x in docker/*; do
    pushd "$x"
    make container &
    popd
done

wait
