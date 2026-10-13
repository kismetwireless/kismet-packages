#!/bin/bash -e

# Launch the modular build inside a build container.
#
# Nightly builds use the live scripts in /scripts/modular-build.  Release
# builds (VERSION set) must use the frozen scripts from a kismet-packages
# git tag, extracted by the host and mounted at /modular-build, with the
# tag name in MODULAR_BUILD_REF.

if test "${BUILD_PLATFORM}"x = "x"; then
    echo "*** BUILD_PLATFORM not set ***"
    exit 1
fi

if test "${VERSION}"x != "x"; then
    if ! test -x /modular-build/modular-build; then
        echo "*** Release build ${VERSION} requires tagged scripts mounted at /modular-build ***"
        exit 1
    fi

    if test "${MODULAR_BUILD_REF}"x = "x"; then
        echo "*** Release build ${VERSION} requires MODULAR_BUILD_REF ***"
        exit 1
    fi

    export BUILD_SCRIPT_ROOT=/modular-build
else
    export BUILD_SCRIPT_ROOT=/scripts/modular-build
    export MODULAR_BUILD_REF="${MODULAR_BUILD_REF:-master}"
fi

exec "${BUILD_SCRIPT_ROOT}/modular-build" "$@"
