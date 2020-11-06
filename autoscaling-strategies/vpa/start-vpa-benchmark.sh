#!/bin/bash

HOST=$1
SERVICE_TIME=100
DURATION=300 #5 minutes

LOGS_DIR=logs
STAGE_DIR=""
SCENARIO_DIR=""
SCENARIOS=(REQUEST_RATE_S1 REQUEST_RATE_S2 REQUEST_RATE_S3 REQUEST_RATE_S4)

# Scenario 1
REQUEST_RATE_S1=(5 10 15 20)

# Scenario 2
REQUEST_RATE_S2=(5 5 20 10)

# Scenario 3
REQUEST_RATE_S3=(20 15 10 5)

# Scenario 4
REQUEST_RATE_S4=(20 5 5 20)



function create_dir(){
    if [ ! -d "${1}" ]; then
        mkdir "${1}"
    fi
    mkdir "${1}/node"
    mkdir "${1}/vpa"
    mkdir "${1}/pods-requests"
}

function save_logs(){

    for value in {1..30}
    do
        (kubectl describe pod busy-wait-vpa | sed -n '26,$p;28q') > "${SCENARIO_DIR}/${STAGE_DIR}/pods-requests/pod-request=${value}-$(date +%r).log"

        (kubectl describe vpa my-vpa | tail -n 13 | sed '$d') > "${SCENARIO_DIR}/${STAGE_DIR}/vpa/vpa=${value}-$(date +%r).log"

        (kubectl top nodes) >> "${SCENARIO_DIR}/${STAGE_DIR}/node/node-usage.log"
        sleep 10;
    done

}

function info(){
    printf "\U1F680 Starting scenario ${1}. It will take 20 minutes...\n"
    printf "\U1F984 Saving pod requests..\n"
    printf "\U1F984 Saving vertical pod autoscaler recommendations..\n"
    printf "\U1F984 Saving information about node usage..\n"
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
            (hey -z ${DURATION}s -c ${REQ_RATE} -q 1 -m GET -T “application/x-www-form-urlencoded” ${HOST}${SERVICE_TIME}) > "${SCENARIO_DIR}/${STAGE_DIR}/hey=${INC}-$(date +%r).log"
            INC=$((INC+1))
        done
        printf "\U1F973  Scenario finished. The logs were saved.\n"
        S_AUX=$((S_AUX+1))
    done
    echo "Experiment finished."
}

start_experiment