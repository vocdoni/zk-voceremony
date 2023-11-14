#!/bin/bash

. scripts/tools.sh

check_last_contribution_env() {
    # get the last contribution zkey file from the contributions file
    if [ ! -f "$CONTRIBUTIONS_FILE" ]; then
        error "contribution file does not exists, is the ceremony initialized?"
        exit 1
    else 
        LAST_CONTRIBUTION_FILE=$(get_last_contribution_file_path)
        LAST_CONTRIBUTION_HASH=$(get_last_contribution_hash)
    fi
    
    mkdir -p $OUTPUT_PATH
}

verify() {
    if [ "$(get_file_hash "$LAST_CONTRIBUTION_FILE")" == "<check CONTRIBUTIONS.md file>" ]; then 
        error "no contributions"
        exit 1
    fi
    if [ "$(get_file_hash "$LAST_CONTRIBUTION_FILE")" != "$LAST_CONTRIBUTION_HASH" ]; then
        error "the last contribution file has been modified, please check the CONTRIBUTIONS.md file"
        exit 1
    fi
    $SNARKJS zkey verify $CONTRIBUTIONS_PATH/$CIRCUIT_FILENAME.r1cs $INPUT_PTAU_PATH $LAST_CONTRIBUTION_FILE 
    # prune temporally files
    rm -rf $OUTPUT_PATH
}

verify_last_contribution() {
    # check the environment
    check_last_contribution_env || error "error checking the environment"
    # verify the result of last contribution
    verify || error "verifying the last contribution"
}

verify_last_contribution