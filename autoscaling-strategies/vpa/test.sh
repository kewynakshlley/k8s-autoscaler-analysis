#!/bin/bash
SCENARIOS=(REQUEST_RATE_S1 REQUEST_RATE_S2 REQUEST_RATE_S3 REQUEST_RATE_S4)

# Scenario 1
REQUEST_RATE_S1=(5 10 15 20)

# Scenario 2
REQUEST_RATE_S2=(5 5 20 10)

# Scenario 3
REQUEST_RATE_S3=(20 15 10 5)

# Scenario 4
REQUEST_RATE_S4=(20 5 5 20)

for scenario in "${SCENARIOS[@]}"
do
    eval AUX=\( \${${scenario}[@]} \)
    for i in "${AUX[@]}"
    do
        echo "$scenario e $i"
        echo ""
    done
done