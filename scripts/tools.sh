#!/bin/bash

# log function helps to print info messages
log() {
	echo "-- [ZK-VOCEREMONY:INFO] -- $1"
}
# error function helps to print error messages
error() {
	echo "-- [ZK-VOCEREMONY:ERROR] -- $1"
	exit 0
}

# include the environment variables
if [ ! -f "./ceremony.env" ]; then
	error "ceremony.env file not found"
	exit 1
else
	set -a            
	source ./ceremony.env
	set +a
fi

HASH=b2sum
CIRCOM=circom
SNARKJS="snarkjs"

CIRCUIT_PATH="${TARGET_CIRCUIT:-"./circuit.circom"}"
INPUT_PTAU_PATH="${INPUT_PTAU:-"./input.ptau"}"

CONTRIBUTIONS_PATH="${CONTRIBUTIONS_PATH:-"./contributions"}"
CONTRIBUTIONS_FILE="$CONTRIBUTIONS_PATH/CONTRIBUTIONS.md"

OUTPUT_PATH="${OUTPUT_PATH:-"./results"}"
OUTPUT_FILE="$OUTPUT_PATH/RESULTS.md"

CIRCUIT_FILE=$(basename -- "$CIRCUIT_PATH")
CIRCUIT_FILENAME="${CIRCUIT_FILE%.*}"


get_file_hash() {
	# get the hash of the file and return the first part, the second part is 
	# the file name
    echo "$($HASH "$1" | cut -d ' ' -f 1)"
}

get_last_contribution_file_path() {
    local last_contribution=$(tail -n 2 $CONTRIBUTIONS_FILE | head -n 1)
    local last_contribution_filepath=$CONTRIBUTIONS_PATH/${CIRCUIT_FILENAME}_initial_contribution.zkey
    if [ "$last_contribution" != "" ]; then
        IFS=":"
        read -ra parts <<< "$last_contribution"
        last_contribution_filepath=$CONTRIBUTIONS_PATH/${parts[0]}
    fi
    echo "$last_contribution_filepath"
}

get_last_contribution_hash() {
    local last_contribution=$(tail -n 2 $CONTRIBUTIONS_FILE | head -n 1)
    local last_contribution_hash="<check CONTRIBUTIONS.md file>"
    if [ "$last_contribution" != "" ]; then
        IFS=":"
        read -ra parts <<< "$last_contribution"
        last_contribution_hash=${parts[1]}
    fi
    echo "$last_contribution_hash"
}