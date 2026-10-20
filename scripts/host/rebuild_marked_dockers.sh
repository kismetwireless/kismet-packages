#!/bin/bash

# Regenerate, in parallel, every docker target with a REGENERATE marker (see
# mark_docker_regenerate.sh), removing each marker once its image is
# regenerated.  Failed targets keep their markers.
#
#   rebuild_marked_dockers.sh [base]
#
# [base] defaults to ~/src/kismet-packages.  Each target logs to
# logs/[target].docker.last.  On a terminal, a line per target shows its
# activity, the step of the image being built, and the elapsed time.

if test $# -eq 0; then
    BASE_DIR="${HOME}/src/kismet-packages"
elif test $# -eq 1; then
    BASE_DIR=$1
else
    echo "Expected [base], or no arguments for ~/src/kismet-packages"
    exit 1
fi

BASE_DIR=$(cd "${BASE_DIR}" && pwd) || exit 1
export BASE_DIR

# docker compose and docker build print one line per build step instead of
# redrawing them when the progress is plain
export BUILDKIT_PROGRESS=plain

TARGETS=()
for m in "${BASE_DIR}"/docker/*/REGENERATE; do
    if test -f "${m}"; then
        TARGETS+=("$(basename "$(dirname "${m}")")")
    fi
done

if test ${#TARGETS[@]} -eq 0; then
    echo "No docker targets are marked for regeneration"
    exit 0
fi

echo "Regenerating ${#TARGETS[@]} docker targets:"
for t in "${TARGETS[@]}"; do
    echo "  ${t}: $(tail -n 1 "${BASE_DIR}/docker/${t}/REGENERATE")"
done
echo

mkdir -p "${BASE_DIR}/logs"
STATUS_DIR=$(mktemp -d "${TMPDIR:-/tmp}/kismet-docker-regen.XXXXXX") || exit 1

PIDS=()
START=$(date +%s)

_CLEANUP() {
    if test -t 1; then
        tput cnorm 2> /dev/null
    fi

    rm -rf "${STATUS_DIR}"
}

_INTERRUPT() {
    _CLEANUP
    echo
    echo "*** Interrupted; stopping docker regeneration, markers are left in place ***"

    for p in "${PIDS[@]}"; do
        pkill -TERM -P "${p}" 2> /dev/null
        kill -TERM "${p}" 2> /dev/null
    done

    exit 130
}

trap _CLEANUP EXIT
trap _INTERRUPT INT TERM

for t in "${TARGETS[@]}"; do
    (
        cd "${BASE_DIR}/docker/${t}" || exit 1

        make container > "${BASE_DIR}/logs/${t}.docker.last" 2>&1 < /dev/null
        rc=$?

        if test ${rc} -eq 0; then
            rm -f REGENERATE
        fi

        echo "${rc} $(date +%s)" > "${STATUS_DIR}/${t}"
    ) &
    PIDS+=($!)
done

# _ELAPSED [seconds]
_ELAPSED() {
    printf "%02d:%02d" $(($1 / 60)) $(($1 % 60))
}

# _STEP [log]
# Print "current total" for the last build step in the log; buildkit names
# steps like "#7 [kismet-build 3/6] RUN ..." or "#7 [3/6] RUN ..."
_STEP() {
    grep -oE '\[[^]]*[0-9]+/[0-9]+\]' "$1" 2> /dev/null | tail -n 1 | grep -oE '[0-9]+/[0-9]+' | tr / ' '
}

# _ACTIVITY [log]
# The last line of the log which says what the build is doing, without the
# buildkit step number and name already shown in the progress
_ACTIVITY() {
    tail -n 50 "$1" 2> /dev/null | tr '\r' '\n' | grep -v -E '^[[:space:]]*$' | tail -n 1 | \
        sed -E 's/^#[0-9]+ //; s/^\[[^]]*[0-9]+\/[0-9]+\] //; s/[[:space:]]+/ /g'
}

SPINNER='|/-\'
NAME_WIDTH=0
for t in "${TARGETS[@]}"; do
    if test ${#t} -gt ${NAME_WIDTH}; then
        NAME_WIDTH=${#t}
    fi
done

# _LINE [index] [tick]
# Print the status line for a target and set its DONE_RC entry once finished
_LINE() {
    t=${TARGETS[$1]}
    log="${BASE_DIR}/logs/${t}.docker.last"
    now=$(date +%s)

    if test -f "${STATUS_DIR}/${t}"; then
        read -r rc end < "${STATUS_DIR}/${t}"
        DONE_RC[$1]=${rc}

        if test "${rc}" = 0; then
            printf "  ok  %-${NAME_WIDTH}s  %s  regenerated" "${t}" "$(_ELAPSED $((end - START)))"
        else
            printf "  !!  %-${NAME_WIDTH}s  %s  FAILED, see logs/%s.docker.last" "${t}" "$(_ELAPSED $((end - START)))" "${t}"
        fi

        return
    fi

    spin=${SPINNER:$((($2 + $1) % 4)):1}

    read -r cur total <<< "$(_STEP "${log}")"
    if test "${total}"x != "x" -a "${total:-0}" -gt 0; then
        filled=$((cur * 10 / total))
        bar=$(printf "%${filled}s" "" | tr ' ' '#')$(printf "%$((10 - filled))s" "" | tr ' ' '.')
        step=$(printf "%2d/%-2d" "${cur}" "${total}")
    else
        bar=".........."
        step="     "
    fi

    printf "  %s   %-${NAME_WIDTH}s  %s  [%s] %s  %s" "${spin}" "${t}" "$(_ELAPSED $((now - START)))" "${bar}" "${step}" "$(_ACTIVITY "${log}")"
}

DONE_RC=()
REPORTED=()
TICK=0

exec 3>&1

if test -t 1; then
    tput civis 2> /dev/null
fi

while true; do
    # Ask the terminal on stdout for its width; tput in a command
    # substitution only sees the pipe
    COLS=$(stty size <&3 2> /dev/null | cut -d ' ' -f 2)
    COLS=${COLS:-80}
    FINISHED=0

    if test -t 1; then
        if test ${TICK} -gt 0; then
            printf "\033[%dA" ${#TARGETS[@]}
        fi

        for i in "${!TARGETS[@]}"; do
            printf "\r\033[K%s\n" "$(_LINE "${i}" "${TICK}" | cut -c "1-$((COLS - 1))")"
        done

        # _LINE runs in a subshell above, so look for finished targets here
        for i in "${!TARGETS[@]}"; do
            if test -f "${STATUS_DIR}/${TARGETS[$i]}"; then
                read -r rc end < "${STATUS_DIR}/${TARGETS[$i]}"
                DONE_RC[$i]=${rc}
                FINISHED=$((FINISHED + 1))
            fi
        done
    else
        # Not a terminal; report each target once as it finishes
        for i in "${!TARGETS[@]}"; do
            if test -f "${STATUS_DIR}/${TARGETS[$i]}"; then
                FINISHED=$((FINISHED + 1))

                if test "${REPORTED[$i]}" != 1; then
                    _LINE "${i}" 0
                    echo
                    REPORTED[$i]=1
                fi
            fi
        done
    fi

    if test ${FINISHED} -eq ${#TARGETS[@]}; then
        break
    fi

    TICK=$((TICK + 1))
    sleep 0.5
done

wait

OK=()
FAILED=()
for i in "${!TARGETS[@]}"; do
    if test "${DONE_RC[$i]}" = 0; then
        OK+=("${TARGETS[$i]}")
    else
        FAILED+=("${TARGETS[$i]}")
    fi
done

echo
echo "*** Docker regeneration complete in $(_ELAPSED $(($(date +%s) - START))) ***"
echo "Regenerated: ${OK[*]}"
echo "Failed:      ${FAILED[*]}"

if test ${#FAILED[@]} -ne 0; then
    echo "*** Failed targets keep their REGENERATE markers ***"
    exit 1
fi
