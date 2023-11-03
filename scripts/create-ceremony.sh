#!/bin/bash

. scripts/tools.sh

check_create_env() {
	echo -e "Welcome to the '$CEREMONY_BRANCH' zk-voceremony creation process!\n"
	echo " - You are using '$CIRCUIT_PATH' as circuit file and '$INPUT_PTAU_PATH' as initial ptau file."
	echo " - This script will compile the circuit and perform the initial contribution."
	echo " - The global artifacts and initial contribution will be stored in '$OUTPUT_PATH' folder."
	echo " - The ceremony information and contributions will be stored in '$CONTRIBUTION_FILE' file."
	# if the -y flag is not present, ask for confirmation
	if [ ! "$1" = "-y" ]; then
	echo -e "\nRemember to commit and push the changes to the ceremony branch after the process is finished.\n"
		read -p "This process will overwrite any previous version. Are you sure? (y/n)" -n 1 -r
		echo -e "\n"
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			exit 1
		fi
	fi
}

compile_circuit() {
	log "compile the target citcuit to get the r1cs file"
	ln -s "$(npm root -g)" /node_modules
	# compilling the circuit
	$CIRCOM $CIRCUIT_PATH --r1cs --wasm -o $OUTPUT_PATH
	# move the wasm file to the root of the output folder
	mv $OUTPUT_PATH/${CIRCUIT_FILENAME}_js/$CIRCUIT_FILENAME.wasm $OUTPUT_PATH/$CIRCUIT_FILENAME.wasm
	# remove the js folder
	rm -rf $OUTPUT_PATH/${CIRCUIT_FILENAME}_js
}

prepare_contribution() {
	log "prepare the contribution using '$INPUT_PTAU_PATH' as initial ptau file"
	$SNARKJS groth16 setup $OUTPUT_PATH/$CIRCUIT_FILENAME.r1cs $INPUT_PTAU_PATH $OUTPUT_PATH/${CIRCUIT_FILENAME}_initial_contribution.zkey
}

save_initial_contribution() {
	log "save the initial contribution to '$CONTRIBUTION_FILE'"
	# calculate the hashes of the global artifacts and initial contribution
	local r1cs_hash=$(get_file_hash "$OUTPUT_PATH/$CIRCUIT_FILENAME.r1cs")
	local wasm_hash=$(get_file_hash "$OUTPUT_PATH/$CIRCUIT_FILENAME.wasm")
	local initial_ptau_hash=$(get_file_hash "$INPUT_PTAU_PATH")
	local initial_zkey_hash=$(get_file_hash "$OUTPUT_PATH/${CIRCUIT_FILENAME}_initial_contribution.zkey")
	# create the contribution file content with the hashes
	local contributions_content="### Global artifacts
- [r1cs](./artifacts/circuit.r1cs) - \`$r1cs_hash\`
- [wasm](./artifacts/circuit.wasm) - \`$wasm_hash\`
- [initial ptau](./artifacts/initial.ptau) - \`$initial_ptau_hash\`

### Contributions
\`\`\`
${CIRCUIT_FILENAME}_initial_contribution.zkey:$initial_zkey_hash
\`\`\`

### Last contribution
\`\`\`

\`\`\`"
	# create the contribution file with the initial content
	echo "$contributions_content" > $CONTRIBUTION_FILE
}

init_ceremony() {
	# check the environment
	check_create_env $1 || error "error checking the environment"
	# create the output folder
	mkdir -p $OUTPUT_PATH
	# compile the circuit
	compile_circuit || error "error compiling circuit"
	# prepare the contribution
	prepare_contribution || error "error preparing contribution"
	# store the initial contribution
	save_initial_contribution || error "error storing initial contribution"
}

init_ceremony $1