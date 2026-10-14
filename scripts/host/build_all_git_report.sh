#!/bin/bash

# Nightly build with error tracking.
#
# Builds every docker target with the modular build system, captures the
# output of each build, publishes the repositories, and writes a report
# listing the status of every target and the reasons for any failure.
#
# Each run is logged to ${BASE_DIR}/logs/nightly-[date]/:
#   [target].log    full output of each build
#   publish.log     output of the repository publish
#   report.txt      summary and failure reasons
#
# logs/nightly-latest links to the most recent run, and logs/[target].last
# holds the latest output of each target as before.
#
# Environment:
#   NIGHTLY_KEEP_RUNS   number of run log directories to keep (default 14)
#   NIGHTLY_REASON_LINES  maximum failure reason lines per target (default 40)

if test $# -ne 2; then
    echo "Expected [base] [src]"
    exit 1
fi

export BASE_DIR=$1
export SRC_DIR=$2
export NCORES=$(nproc)

NIGHTLY_KEEP_RUNS=${NIGHTLY_KEEP_RUNS:-14}
NIGHTLY_REASON_LINES=${NIGHTLY_REASON_LINES:-40}

if test -e ${BASE_DIR}/pause; then
    echo "Paused"
    exit
fi

RUN_START=$(date +%s)
RUN_DIR=${BASE_DIR}/logs/nightly-$(date '+%Y-%m-%d-%H%M%S')
REPORT=${RUN_DIR}/report.txt

mkdir -p ${RUN_DIR} || exit 1
ln -sfn $(basename ${RUN_DIR}) ${BASE_DIR}/logs/nightly-latest
rm -f ${BASE_DIR}/logs/*.last

# Lines which explain a failure: modular build failures and the package logs
# it prints, verify-deps findings, configure and compiler errors, the kernel
# OOM killer, and docker errors
FAILURE_PATTERN='FAILED|^\*\*\* .*(not set|requires|does not|[Uu]nknown|must be)|^\[[a-z0-9.+-]+\] |verify-deps:|configure: error|[Ee]rror:|ERROR|Error [0-9]+|Killed signal|No space left|Error response from daemon|failed to solve|no such service|Cannot connect to the Docker daemon|E: '

# _DURATION [seconds]
_DURATION() {
    printf '%d:%02d:%02d' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60))
}

# _FAILURE_REASONS [log]
_FAILURE_REASONS() {
    REASONS=$(grep -E "${FAILURE_PATTERN}" "$1" | grep -v '^\*\*\* Packaged' | head -n ${NIGHTLY_REASON_LINES})

    if test "${REASONS}"x = "x"; then
        echo "(no recognized error message; last lines of output)"
        tail -n 20 "$1"
    else
        echo "${REASONS}"
    fi
}

TARGETS=()
declare -A STATUS
declare -A ELAPSED

for d in ${BASE_DIR}/docker/*; do
    t=$(basename ${d})
    TARGETS+=(${t})

    echo "*** $(date '+%H:%M:%S') building ${t} ***"

    START=$(date +%s)
    ${BASE_DIR}/scripts/host/modular_build_single.sh ${BASE_DIR} ${SRC_DIR} ${t} > ${RUN_DIR}/${t}.log 2>&1
    RC=$?
    ELAPSED[${t}]=$(($(date +%s) - START))

    cp ${RUN_DIR}/${t}.log ${BASE_DIR}/logs/${t}.last

    case ${RC} in
        0)
            if grep -q "no build required" ${RUN_DIR}/${t}.log; then
                STATUS[${t}]="unchanged"
            else
                STATUS[${t}]="built"
            fi
            ;;
        2)
            STATUS[${t}]="skipped"
            ;;
        *)
            STATUS[${t}]="FAILED"
            ;;
    esac

    echo "*** $(date '+%H:%M:%S') ${t} ${STATUS[${t}]} ($(_DURATION ${ELAPSED[${t}]})) ***"
done

echo "*** $(date '+%H:%M:%S') publishing repositories ***"

${BASE_DIR}/scripts/host/aptly_update_repos.sh ${BASE_DIR} > ${RUN_DIR}/publish.log 2>&1
PUBLISH_RC=$?

# Write the report

COUNT_BUILT=0
COUNT_UNCHANGED=0
COUNT_SKIPPED=0
COUNT_FAILED=0

{
    echo "Kismet nightly build $(date -d @${RUN_START} '+%Y-%m-%d %H:%M:%S' 2> /dev/null || date -r ${RUN_START} '+%Y-%m-%d %H:%M:%S')"
    echo "Kismet source:     $(git -C ${SRC_DIR} rev-parse --short HEAD 2> /dev/null || echo unknown)"
    echo "Packaging scripts: $(git -C ${BASE_DIR} rev-parse --short HEAD 2> /dev/null || echo unknown)"
    echo "Logs:              ${RUN_DIR}"
    echo

    printf '%-28s %-10s %s\n' "TARGET" "STATUS" "TIME"
    for t in "${TARGETS[@]}"; do
        printf '%-28s %-10s %s\n' ${t} ${STATUS[${t}]} $(_DURATION ${ELAPSED[${t}]})

        case ${STATUS[${t}]} in
            built) COUNT_BUILT=$((COUNT_BUILT + 1)) ;;
            unchanged) COUNT_UNCHANGED=$((COUNT_UNCHANGED + 1)) ;;
            skipped) COUNT_SKIPPED=$((COUNT_SKIPPED + 1)) ;;
            *) COUNT_FAILED=$((COUNT_FAILED + 1)) ;;
        esac
    done

    echo
    echo "Built: ${COUNT_BUILT}  Unchanged: ${COUNT_UNCHANGED}  Skipped: ${COUNT_SKIPPED}  Failed: ${COUNT_FAILED}"

    if test ${PUBLISH_RC} -eq 0; then
        echo "Publish: ok"
    else
        echo "Publish: FAILED (exit ${PUBLISH_RC})"
    fi

    echo "Total time: $(_DURATION $(($(date +%s) - RUN_START)))"

    if test ${COUNT_FAILED} -ne 0 -o ${PUBLISH_RC} -ne 0; then
        echo
        echo "==================== FAILURES ===================="
    fi

    for t in "${TARGETS[@]}"; do
        if test "${STATUS[${t}]}" = "FAILED"; then
            echo
            echo "---- ${t} (${RUN_DIR}/${t}.log)"
            _FAILURE_REASONS ${RUN_DIR}/${t}.log
        fi
    done

    if test ${PUBLISH_RC} -ne 0; then
        echo
        echo "---- publish (${RUN_DIR}/publish.log)"
        _FAILURE_REASONS ${RUN_DIR}/publish.log
    fi
} > ${REPORT}

cat ${REPORT}

# Remove old run logs
ls -1d ${BASE_DIR}/logs/nightly-20* 2> /dev/null | sort | head -n -${NIGHTLY_KEEP_RUNS} | xargs -r rm -rf

if test ${COUNT_FAILED} -ne 0 -o ${PUBLISH_RC} -ne 0; then
    exit 1
fi
