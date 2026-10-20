#!/bin/bash

# Regenerate every docker image, from the kismet-packages directory.  A
# target's REGENERATE marker is removed once its image is regenerated.

for x in docker/*/; do
    ( cd "$x" && make container && rm -f REGENERATE ) &
done

FAILED=0
for j in $(jobs -p); do
    wait "$j" || FAILED=1
done

exit ${FAILED}
