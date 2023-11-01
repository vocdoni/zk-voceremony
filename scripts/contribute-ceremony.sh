#!/bin/bash

. scripts/tools.sh

SNARKJS="snarkjs"

check_contribute_env() {
    # check the global environment
    check_env
    # get the last contribution zkey file from the contributions file
    if [ ! -f "$CONTRIBUTION_FILE" ]; then
        error "contribution file does not exists, is the ceremony initialized?"
        exit 1
    else 
        LAST_CONTRIBUTION_DATA=$(tail -n 2 CONTRIBUTIONS.md | head -n 1)
        if [ "$LAST_CONTRIBUTION_DATA" == "" ]; then
            # no last contribution, get the initial one
            LAST_CONTRIBUTION_FILE=$OUTPUT_PATH/${CIRCUIT_FILENAME}_initial_contribution.zkey
            LAST_CONTRIBUTION_HASH="<check CONTRIBUTIONS.md file>"
        else 
            # get the last contribution zkey file based on the hash of the last contribution
            IFS=":"
            read -ra PARTS <<< "$LAST_CONTRIBUTION_DATA"
            LAST_CONTRIBUTION_FILE=$OUTPUT_PATH/${PARTS[0]}
            LAST_CONTRIBUTION_HASH=${PARTS[1]}
        fi
    fi

    while true; do
        read -p "Please enter your alias as contributor: " CONTRIBUTOR_NAME
        # Check if the alias is not empty
        if [ -n "$CONTRIBUTOR_NAME" ]; then
            break
        else
            echo "Alias cannot be empty."
        fi
    done

    echo -e "\nWelcome to the '$CEREMONY_BRANCH' zk-voceremony contribution process!\n"
    echo "Thanks $CONTRIBUTOR_NAME for your contribution!"
    echo " - You are using $LAST_CONTRIBUTION_FILE as last contribution file ($HASH: $LAST_CONTRIBUTION_HASH)"
    echo " - Your contribution will be saved in $OUTPUT_PATH/${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey file"
    echo -e "\nRemember to commit and push the changes to the ceremony branch after the process is finished.\n"
}

make_contribution() {
    $SNARKJS zkc $LAST_CONTRIBUTION_FILE $OUTPUT_PATH/${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey
}

init_contribution() {
    check_contribute_env
    make_contribution || error "contribution failed"
    append_hash_to_contributions "$OUTPUT_PATH/${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey"
}

init_contribution