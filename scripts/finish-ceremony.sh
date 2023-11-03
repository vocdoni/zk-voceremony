#!/bin/bash

. scripts/tools.sh

check_finish_env() {
	echo -e "Welcome to the '$CEREMONY_BRANCH' zk-voceremony ends process!\n"
	echo " - You are using '$CIRCUIT_PATH' as circuit file and '$INPUT_PTAU_PATH' as initial ptau file."
	echo " - This script will finish the ceremony and verify the result."
	echo " - The results and initial contribution will be stored in '$OUTPUT_PATH' folder."
	echo " - The ceremony information and contributions will be stored in '$CONTRIBUTIONS_FILE' file."

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

finish_and_verify() {
    $SNARKJS zkey beacon $LAST_CONTRIBUTION_FILE $OUTPUT_PATH/${CIRCUIT_FILENAME}_proving_key.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
    $SNARKJS zkey verify $CONTRIBUTIONS_PATH/$CIRCUIT_FILENAME.r1cs $INPUT_PTAU_PATH $OUTPUT_PATH/${CIRCUIT_FILENAME}_proving_key.zkey 
    $SNARKJS zkey export verificationkey $OUTPUT_PATH/${CIRCUIT_FILENAME}_proving_key.zkey  $OUTPUT_PATH/${CIRCUIT_FILENAME}_verification_key.json
}

save_results() {
    cp $CONTRIBUTIONS_PATH/$CIRCUIT_FILENAME.wasm $OUTPUT_PATH/${CIRCUIT_FILENAME}.wasm
    local wasm_hash=$(get_file_hash "$OUTPUT_PATH/$CIRCUIT_FILENAME.wasm")
    local pkey_hash=$(get_file_hash "$OUTPUT_PATH/${CIRCUIT_FILENAME}_proving_key.zkey")
    local vkey_hash=$(get_file_hash "$OUTPUT_PATH/${CIRCUIT_FILENAME}_verification_key.json")

    echo "# '$CEREMONY_BRANCH' ceremony results
- [$OUTPUT_PATH/$CIRCUIT_FILENAME.wasm]($OUTPUT_PATH/$CIRCUIT_FILENAME.wasm) - \`$wasm_hash\`
- [$OUTPUT_PATH/${CIRCUIT_FILENAME}_proving_key.zkey]($OUTPUT_PATH/${CIRCUIT_FILENAME}_proving_key.zkey) - \`$pkey_hash\`
- [$OUTPUT_PATH/${CIRCUIT_FILENAME}_verification_key.json]($OUTPUT_PATH/${CIRCUIT_FILENAME}_verification_key.json) - \`$vkey_hash\`" > $OUTPUT_FILE
}

finish_ceremony() {
    # check the environment
    check_finish_env || error "error checking the environment"
    # finish the ceremony and verify the result generating the proving key and 
    # the verification key
    finish_and_verify || error "error finishing the ceremony or verifying the result"
    # save the results in the results file with the hashes of the generated
    # files
    save_results || error "error saving the results"
}

finish_ceremony