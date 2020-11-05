#!/bin/bash

HOST=$1
SERVICE_TIME=100
DURATIONS=(300 300 300 300)

LOGS_DIR=logs
LOG_SUBDIR=""

# Scenario 1
REQUEST_RATE_S1=(5 10 15 20)

# Scenario 2
REQUEST_RATE_S2=(5 5 20 10)

# Scenario 3
REQUEST_RATE_S3=(20 15 10 5)

# Scenario 4
REQUEST_RATE_S4=(20 5 5 20)


REQUEST_RATE=(5 10 20 5)


function create_dir(){
    if [ ! -d "$LOGS_DIR" ]; then
        mkdir "$LOGS_DIR"
    fi
    mkdir "logs/$1"
    mkdir "logs/${1}/node"
    mkdir "logs/${1}/vpa"
    mkdir "logs/${1}/pod-requests"
}

function cpu_usage_requests(){
    printf "\U1F984 Saving pod requests..\n"
    printf "\U1F984 Saving vertical pod autoscaler recommendations..\n"
    printf "\U1F984 Saving information about node usage..\n"
    echo "It will take 5 minutes.."
    for value in {1..30}
    do
        (kubectl describe pod slave-leech-deployment | sed -n '26,$p;28q') > "logs/${LOG_SUBDIR}/pod-requests/pod-requests=${value}-$(date +%r).log"

        (kubectl describe vpa my-vpa | tail -n 13 | sed '$d') > "logs/${LOG_SUBDIR}/vpa/vpa=${value}-$(date +%r).log"

        (kubectl top nodes) >> "logs/${LOG_SUBDIR}/node/node-usage.log"
        sleep 10;
    done
    echo "Done"
}

function generate_workload(){
    for value in {0..3}
    do
        LOG_SUBDIR="bench_$value"
        create_dir $LOG_SUBDIR

        echo "Starting benchmark with duration = ${DURATIONS[value]} and request rate = ${REQUEST_RATE[value]}"
        cpu_usage_requests &
        (hey -z ${DURATIONS[value]}s -c ${REQUEST_RATE[value]} -q 1 -m GET -T “application/x-www-form-urlencoded” ${HOST}${SERVICE_TIME}) > "logs/${LOG_SUBDIR}/hey=${value}-$(date +%r).log"
        echo "Benchmark number $value finished."
    done
    echo "Experiment finished."
}

generate_workload

