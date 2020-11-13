#!/bin/bash

HOST=$1
SERVICE_TIME=250
DURATION=2 #5 minutes

LOGS_DIR=logs
STAGE_DIR=""
SCENARIO_DIR=""
SCENARIOS=(REQUEST_RATE_S1 REQUEST_RATE_S2 REQUEST_RATE_S3)

# Scenario 1
REQUEST_RATE_S1=(2 4 8 8 4 2)

# Scenario 2
REQUEST_RATE_S2=(1 1 8 8 1 1)

# Scenario 3
REQUEST_RATE_S3=(1 8 1 8 1 8)



function create_dir(){
    if [ ! -d "${1}" ]; then
        mkdir "${1}"
    fi
    mkdir "${1}/node"
    mkdir "${1}/vpa"
    mkdir "${1}/pods-requests"
    mkdir "${1}/pods-usage"
}

function save_logs(){

    for value in {1..30}
    do
        (kubectl get pods -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/pods-requests/pod-request-${value}.log"

        (kubectl get vpa busy-wait-vpa -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/vpa/vpa-${value}.log"

        (kubectl top nodes) >> "${SCENARIO_DIR}/${STAGE_DIR}/node/node-usage.log"

        (kubectl top pods) >> "${SCENARIO_DIR}/${STAGE_DIR}/pods-usage/pods-usage.log"
        sleep 10;
    done

}

function info(){
    printf "\U1F680 Starting scenario ${1}. It will take 20 minutes...\n"
    printf "\U1F984 Saving pod requests..\n"
    printf "\U1F984 Saving vertical pod autoscaler recommendations..\n"
    printf "\U1F984 Saving information about node usage..\n"
    printf "\U1F984 Saving information about pods usage..\n"
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
            echo "RATE LIMIT $REQ_RATE"
            STAGE_DIR="stage-${INC}"
            create_dir "${SCENARIO_DIR}/${STAGE_DIR}"

            save_logs &
            (hey -disable-keepalive -z ${DURATION}m -c ${REQ_RATE} -q 1 -m GET -T “application/x-www-form-urlencoded” ${HOST}${SERVICE_TIME}) > "${SCENARIO_DIR}/${STAGE_DIR}/hey=${INC}-$(date +%r).log"
            INC=$((INC+1))
        done
        printf "\U1F973  Scenario finished. The logs were saved.\n"
        S_AUX=$((S_AUX+1))
    done
    echo "Experiment finished."
}

start_experiment