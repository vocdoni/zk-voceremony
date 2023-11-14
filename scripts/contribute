#!/bin/bash

prompt_env_inputs() {
    echo "Welcome to the zk-voceremony contribution process!
    "
    echo "To start your contribution you need to provide the following information:"
    echo " - Login to your GitHub account (including your github username and email to commit yout contribution)"
    echo " - The URL of the repository of the ceremony (by default 'https://github.com/vocdoni/zk-voceremony.git')"
    echo " - The name of the ceremony (used to name the ceremony branch)"

    while true; do
        read -p "Enter yout Github username: " CONTRIBUTOR_NAME
        # Check if the alias is not empty
        if [ -n "$CONTRIBUTOR_NAME" ]; then
            break
        fi
    done
    while true; do
        read -p "Enter yout Github email: " CONTRIBUTOR_EMAIL
        # Check if the alias is not empty
        if [ -n "$CONTRIBUTOR_EMAIL" ]; then
            break
        fi
    done

    GITHUB_REPO_URL="https://github.com/vocdoni/zk-voceremony.git"
    read -p "Enter the url of the repo (by default 'https://github.com/vocdoni/zk-voceremony.git'): " REPO_URL
    if [ -n "$REPO_URL" ]; then
        GITHUB_REPO_URL=$REPO_URL
    fi
    # get the access token
    gh auth login -p https -h github.com -w
    # clone the ceremony branch
    echo "Cloning ceremony branch..."
    gh repo clone $GITHUB_REPO_URL ./ceremony
    cd ./ceremony
    # set up user identity
    git config user.name $CONTRIBUTOR_NAME
    git config user.email $CONTRIBUTOR_EMAIL
    # list on-going ceremonies
    gh pr list -l on-going-ceremony
    echo
    while true; do
        read -p "Enter the name of one of the 'on-going' ceremonies and branches shown above: " CEREMONY_BRANCH
        # Check if the alias is not empty
        if [ -n "$CEREMONY_BRANCH" ]; then
            break
        fi
    done

    git checkout $CEREMONY_BRANCH
    git pull origin $CEREMONY_NAME
    git lfs fetch
    git lfs pull
    echo
    read -p "Okey! Let's start. Press enter to continue..."
    . scripts/tools.sh
}

check_contribute_env() {
    # get the last contribution zkey file from the contributions file
    if [ ! -f "$CONTRIBUTIONS_FILE" ]; then
        error "contribution file does not exists, is the ceremony initialized?"
        exit 1
    else 
        LAST_CONTRIBUTION_FILE=$(get_last_contribution_file_path)
        LAST_CONTRIBUTION_HASH=$(get_last_contribution_hash)
    fi

    CURRENT_CONTRIBUTION_FILENAME=${CIRCUIT_FILENAME}_${CONTRIBUTOR_NAME}.zkey
    counter=0
    while [ -e "$CONTRIBUTIONS_PATH/$CURRENT_CONTRIBUTION_FILENAME" ]; do
        counter=$((counter + 1))
        CURRENT_CONTRIBUTION_FILENAME="${CURRENT_CONTRIBUTION_FILENAME%.*}_${counter}.${CURRENT_CONTRIBUTION_FILENAME##*.}"
    done
    CURRENT_CONTRIBUTION_FILE="$CONTRIBUTIONS_PATH/$CURRENT_CONTRIBUTION_FILENAME"

    echo
    echo "Welcome to the '$CEREMONY_BRANCH' zk-voceremony contribution process!
    "
    echo "Thanks $CONTRIBUTOR_NAME for your contribution!"
    echo " - You are using $LAST_CONTRIBUTION_FILE as last contribution file ($HASH: $LAST_CONTRIBUTION_HASH)"
    echo " - Your contribution will be saved in $CURRENT_CONTRIBUTION_FILE file"
    echo
    echo "Now, the script will prompt to you for an random input to generate the new contribution."
    echo "This process will take a while... So, be patient and don't close the terminal until the process is finished.
    "
}

make_contribution() {
    $SNARKJS zkc $LAST_CONTRIBUTION_FILE $CURRENT_CONTRIBUTION_FILE
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

publish_contribution() {
    git add $CONTRIBUTIONS_FILE $CURRENT_CONTRIBUTION_FILE
	git commit -m "New contribution"
	git push origin $CEREMONY_BRANCH
}

init_contribution() {
    prompt_env_inputs
    check_contribute_env
    make_contribution || error "contribution failed"
    append_hash_to_contributions "$CURRENT_CONTRIBUTION_FILE"
    publish_contribution || error "publish contribution failed"
}

init_contribution