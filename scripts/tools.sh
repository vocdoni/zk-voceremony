#!/bin/bash

# log function helps to print info messages
log() {
	echo "-- [ZK-VOCEREMONY:INFO] -- $1"
}
# error function helps to print error messages
error() {
	echo "-- [ZK-VOCEREMONY:ERROR] -- $1"
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
OUTPUT_PATH="${OUTPUT_PATH:-"./artifacts"}"

CIRCUIT_FILE=$(basename -- "$CIRCUIT_PATH")
CIRCUIT_FILENAME="${CIRCUIT_FILE%.*}"
CONTRIBUTION_FILE="${CONTIBUTIONS_PATH:-"CONTRIBUTIONS.md"}"

get_file_hash() {
	# get the hash of the file and return the first part, the second part is 
	# the file name
    echo "$($HASH "$1" | cut -d ' ' -f 1)"
}