#!/bin/bash

. scripts/tools.sh

check_contribute_env() {
    # get the last contribution zkey file from the contributions file
    if [ ! -f "$CONTRIBUTIONS_FILE" ]; then
        error "contribution file does not exists, is the ceremony initialized?"
        exit 1
    else 
        LAST_CONTRIBUTION_FILE=$(get_last_contribution_file_path)
        LAST_CONTRIBUTION_HASH=$(get_last_contribution_hash)
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
    echo " - Your contribution will be saved in $CONTRIBUTIONS_PATH/${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey file"
    echo -e "\nRemember to commit and push the changes to the ceremony branch after the process is finished.\n"
}

make_contribution() {
    $SNARKJS zkc $LAST_CONTRIBUTION_FILE $CONTRIBUTIONS_PATH/${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey
}

append_hash_to_contributions() {
	local contribution_hash=$(get_file_hash "$1")
	local contribution_filepath=$(basename -- "$1")
	local contribution_line="$contribution_filepath:$contribution_hash"
	# calculate the target line to append the contribution hash
	total_lines=$(wc -l < "$CONTRIBUTIONS_FILE")
	contribution_target_line=$((total_lines - 6))
	last_contribution_target_line=$((total_lines))
	# create a temporary file
    temp_file=$(mktemp)
    # copy lines up to the target line to the temporary file
    head -n "$contribution_target_line" "$CONTRIBUTIONS_FILE" > "$temp_file"
    # append the new content
    echo "$contribution_line" >> "$temp_file"
    # append the remaining lines after the new content
    tail -n +$((contribution_target_line + 1)) "$CONTRIBUTIONS_FILE" >> "$temp_file"
    # replace the original file with the temporary file including the new 
	# last contribution hash
	sed "${last_contribution_target_line}s/.*/$contribution_line/" $temp_file > "$CONTRIBUTIONS_FILE"
}

init_contribution() {
    check_contribute_env
    make_contribution || error "contribution failed"
    append_hash_to_contributions "$CONTRIBUTIONS_PATH/${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey"
}

init_contribution