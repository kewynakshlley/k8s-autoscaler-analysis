#!/bin/bash

HOST=""
SERVICE_TIME='/busy-wait/250'
DURATION=2

LOGS_DIR=logs
STAGE_DIR=""
SCENARIO_DIR=""
SCENARIOS=(REQUEST_RATE_S1 REQUEST_RATE_S2 REQUEST_RATE_S3 REQUEST_RATE_S4 REQUEST_RATE_S5)

# Scenario 1
REQUEST_RATE_S1=(2 2 4 6 8 6 4 2)

# Scenario 2
REQUEST_RATE_S2=(2 2 4 4 8 8 4 4)

# Scenario 3
REQUEST_RATE_S3=(2 2 8 8 8 2 2 2)

# Scenario 4
REQUEST_RATE_S4=(2 2 8 8 2 2 8 8)

# Scenario 4
REQUEST_RATE_S5=(2 2 8 2 8 2 8 2)

function create_dir(){
    if [ ! -d "${1}" ]; then
        mkdir "${1}"
    fi
    mkdir "${1}/hpa"
    mkdir "${1}/hpa-json"
    mkdir "${1}/events"
    mkdir "${1}/pods-requests"
}

function save_logs(){
    for value in {1..12}
    do
        (kubectl get hpa busy-wait-hpa) >> "${SCENARIO_DIR}/${STAGE_DIR}/hpa/hpa-usage.log"
        (kubectl get pods -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/pods-requests/pod-request-${value}.log"
        (kubectl get hpa busy-wait-hpa -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/hpa-json/hpa-${value}.log"
        sleep 10;
    done
}

function info(){
    printf "\U1F680 Starting scenario ${1}. It will take 20 minutes...\n"
    printf "\U1F984 Saving HPA usage info..\n"
    printf "\U1F984 Saving node info..\n"
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

            (kubectl describe nodes minikube) > "${SCENARIO_DIR}/${STAGE_DIR}/node-info.log"
            echo "REQUEST RATE = $REQ_RATE"
            HOST=$(minikube service busy-wait-hpa --url)
            save_logs &
            (hey -disable-keepalive -z ${DURATION}m -c ${REQ_RATE} -q 1 -m GET -T “application/x-www-form-urlencoded” ${HOST}${SERVICE_TIME}) > "${SCENARIO_DIR}/${STAGE_DIR}/hey-info.log"
            (kubectl get hpa busy-wait-hpa -o json) > "${SCENARIO_DIR}/${STAGE_DIR}/events/events-info.log"

            INC=$((INC+1))
        done
        printf "\U1F973  Scenario finished. The logs were saved.\n"
        S_AUX=$((S_AUX+1))
        source restart-hpa.sh
    done
    echo "Experiment finished."
}

start_experiment