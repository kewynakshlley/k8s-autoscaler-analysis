#!/bin/bash

HOST=$1
SERVICE_TIME='busy-wait/175'
DURATION=2

LOGS_DIR=logs
STAGE_DIR=""
SCENARIO_DIR=""
SCENARIOS=(REQUEST_RATE_S1 REQUEST_RATE_S2 REQUEST_RATE_S3 REQUEST_RATE_S4)

# Scenario 1
REQUEST_RATE_S1=(1 1 2 4 8 4 2 1)

# Scenario 2
REQUEST_RATE_S2=(1 1 8 8 8 1 1 1)

# Scenario 3
REQUEST_RATE_S3=(1 1 8 8 1 1 8 8)

# Scenario 4
REQUEST_RATE_S4=(1 1 8 1 8 1 8 1)

function create_dir(){
    if [ ! -d "${1}" ]; then
        mkdir "${1}"
    fi
    mkdir "${1}/node"
    mkdir "${1}/hpa"
    mkdir "${1}/events"
    mkdir "${1}/pods-requests"
}

function save_logs(){
    for value in {1..12}
    do
        (kubectl get hpa slave-leech-hpa) >> "${SCENARIO_DIR}/${STAGE_DIR}/hpa/hpa-usage.log"
        (kubectl get pods -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/pods-requests/pod-request-${value}.log"
        (kubectl top nodes) >> "${SCENARIO_DIR}/${STAGE_DIR}/node/node-usage.log"
        sleep 10;
    done
}

function info(){
    printf "\U1F680 Starting scenario ${1}. It will take 20 minutes...\n"
    printf "\U1F984 Saving HPA usage info..\n"
    printf "\U1F984 Saving information about node usage..\n"
    printf "\U1F984 Saving HPA events..\n"
}

function start_experiment(){
    S_AUX=1
    for scenario in "${SCENARIOS[@]}"
    do
        eval SCENARIO_NAME=\( \${${scenario}[@]} \)
        INC=1

        SCENARIO_DIR="scenario-${S_AUX}"
        mkdir $SCENARIO_DIR

        info ${S_AUX}

        for REQ_RATE in "${SCENARIO_NAME[@]}"
        do
            STAGE_DIR="stage-${INC}"
            create_dir "${SCENARIO_DIR}/${STAGE_DIR}"

            save_logs &
            (hey -z ${DURATION}m -c ${REQ_RATE} -q 1 -m GET -T “application/x-www-form-urlencoded” ${HOST}${SERVICE_TIME}) > "${SCENARIO_DIR}/${STAGE_DIR}/hey=${INC}-$(date +%r).log"
            (kubectl get hpa busy-wait-hpa -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/events/events=${INC}.log"

            INC=$((INC+1))
        done
        printf "\U1F973  Scenario finished. The logs were saved.\n"
        S_AUX=$((S_AUX+1))
    done
    echo "Experiment finished."
}

start_experiment