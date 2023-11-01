#!/usr/bin/env bash

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

CIRCUIT_PATH="${TARGET_CIRCUIT:-"./circuit.circom"}"
INPUT_PTAU_PATH="${INPUT_PTAU:-"./input.ptau"}"
OUTPUT_PATH="${OUTPUT_PATH:-"./artifacts"}"

CIRCUIT_FILE=$(basename -- "$CIRCUIT_PATH")
CIRCUIT_FILENAME="${CIRCUIT_FILE%.*}"
CONTRIBUTION_FILE="${CONTIBUTIONS_PATH:-"CONTRIBUTIONS.md"}"
CURRENT_BRANCH=$(git branch --show-current)

check_env() {
	if [ -z "$CEREMONY_BRANCH" ]; then
		error "CEREMONY_BRANCH env var is not set."
		exit 1
	fi

	if [ "$CURRENT_BRANCH" == "main" ]; then
		error "you are in the main branch, please checkout the ceremony branch to contribute"
		exit 1
	elif [ "$CURRENT_BRANCH" != "$CEREMONY_BRANCH" ]; then
		error "you are in the wrong branch, please checkout the ceremony branch to contribute"
		exit 1
	fi
}

get_file_hash() {
	# get the hash of the file and return the first part, the second part is 
	# the file name
    echo "$($HASH "$1" | cut -d ' ' -f 1)"
}

append_hash_to_contributions() {
	local contribution_hash=$(get_file_hash "$1")
	local contribution_filepath=$(basename -- "$1")
	local contribution_line="$contribution_filepath:$contribution_hash"
	# calculate the target line to append the contribution hash
	total_lines=$(wc -l < "$CONTRIBUTION_FILE")
	contribution_target_line=$((total_lines - 6))
	last_contribution_target_line=$((total_lines))
	# create a temporary file
    temp_file=$(mktemp)
    # copy lines up to the target line to the temporary file
    head -n "$contribution_target_line" "$CONTRIBUTION_FILE" > "$temp_file"
    # append the new content
    echo "$contribution_line" >> "$temp_file"
    # append the remaining lines after the new content
    tail -n +$((contribution_target_line + 1)) "$CONTRIBUTION_FILE" >> "$temp_file"
    # replace the original file with the temporary file including the new 
	# last contribution hash
	sed "${last_contribution_target_line}s/.*/$contribution_line/" $temp_file > "$CONTRIBUTION_FILE"
}