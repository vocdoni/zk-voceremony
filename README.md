# ZK VoCeremony

This repo contains a toolkit for creating and contributing to a zk ceremony, using this repo to track the whole process in a separate branch for each ceremony. 

The toolkit only supports Circom circuits, and only makes sense for proving systems that require a specific trusted ceremony (e.g. Groth16). It uses [Circom](https://docs.circom.io/) to compile the circuits and [SnarkJS](https://github.com/iden3/snarkjs) to generate the circuit artifacts, create ceremonies and perform contributions.

## Zk Ceremonies

A zk ceremony is a multy-party computation process to generate the required inputs to use a zk snark circuit in a secure and reliable way, a *trusted setup*. This trusted setup includes two resulting keys:
* The proving key: Used to generate zk proofs using the circuit for which it was generated.
* The verifiying key: Used to verify these proofs.

This process also produces a piece of data called *toxic waste* which must be discarded, as it can be used to generate fake proofs. And this is because it is performed as a multy-party computation, to reduce the risks of the process distributing it in multiple participants.

In turn, each party takes the previous contribution (starting from an initial one generated during the creation of the ceremony) and contributes with a random input to generate entropy at the output. Then, the result of the process is uploaded and the toxic-waste is discarded. 

The process can be repeated through the participants in rounds until the ceremony ends (the number of rounds is determined during the ceremony creation process).

You can read more about trusted zk ceremonies [here](https://zkproof.org/2021/06/30/setup-ceremonies/).

## How to use the toolkit?

### 0. Requirements 

* **Git and a Github account** with permissions push to non main branches of this repository. The process will be stored and tracked in a branch of the current GitHub repository.
* **Docker**: The toolkit uses docker containers to avoid installing dependencies on the host machine and to avoid incompatibilities.
* **Makefile**: As a CLI. It performs some checks such as if the previous dependencies are available or if the user have the correct environment in every process stage. 

### 1. Create a new zk-ceremony
**A.** Create a new branch for your ceremony from `main`:
```sh
git checkout -b {ceremony_name}
```

**B.** Copy your circuit file and your phase 1 *Powers of Tau* file:
```sh
cp /path/to/your/circuit/{circuit_name}.circom ./{circuit_name}.circom
cp /path/to/your/{initial_ptau}.ptau ./{initial_ptau}.ptau
```
You can use one of the Perpetual Power of Tau from [here](https://github.com/iden3/snarkjs?tab=readme-ov-file#7-prepare-phase-2) based on the number of constrains of your circuit. Read more [here](https://github.com/privacy-scaling-explorations/perpetualpowersoftau) about Perpetual Powers of Tau.

**C.** Copy `example.env` to `ceremony.env` and complete with your information or:
```sh
echo "TARGET_CIRCUIT=./{circuit_name}.circom
INPUT_PTAU=./{initial_ptau}.ptau
CEREMONY_BRANCH={ceremony_name}" > ceremony.env
```

**D.** Init the creation and follow the instructions:
```sh
make create
```

This will create:
 * `./artifacts/`: A new folder with the `wasm` compiled circuit, the circuit R1CS definition and the initial circuit `zkey` contribution.
 * `./CONTRIBUTIONS.md`: A new file to track the files checksums for every contribution.

**E.** Upload and start the ceremony:
```sh
git add artifacts/{circuit_name}.wasm \
    artifacts/{circuit_name}.r1cs \
    artifacts/{circuit_name}_initial_contribution.zkey \
    CONTRIBUTION.md
git commit -m "{your commit message}"
git push origin {ceremony_name}
```

### 2. Contribute to a ceremony

**A.** Checkout the ceremony branch:
```sh
git fetch origin
git checkout {ceremony_name}
git pull origin {ceremony_name}
```

**B.** Init the contribution and follow the instructions:
```sh
make contribute
```
This will create:
 * `./artifacts/{circuite_name}_{contributor_alias}.zkey`: The result of your contribution.

And will update:
 * `./CONTRIBUTIONS.md`: Add your contribution filename and checksum to the list of contributions and set it as the last contribution.

**C.** Upload your contribution:
```sh
git add artifacts/{circuite_name}_{contributor_alias}.zkey CONTRIBUTION.md
git commit -m "{your commit message}"
git push origin {ceremony_name}
```