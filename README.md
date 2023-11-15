# ZK VoCeremony

This repo contains a toolkit for creating and contributing to a zk ceremony, using this repo to track the whole process in a separate branch for each ceremony. 

The toolkit only supports Circom circuits, and only makes sense for proving systems that require a specific trusted ceremony (e.g. Groth16). It uses [Circom](https://docs.circom.io/) to compile the circuits and [SnarkJS](https://github.com/iden3/snarkjs) to generate the circuit artifacts, create ceremonies and perform contributions.

## Trusted Ceremonies

A zk ceremony o trusted ceremony, is a multy-party computation process to generate the required inputs to use a zk snark circuit in a secure and reliable way, a *trusted setup*. This trusted setup includes two resulting keys:
* The proving key: Used to generate zk proofs using the circuit for which it was generated.
* The verifiying key: Used to verify these proofs.

This process also produces a piece of data called *toxic waste* which must be discarded, as it can be used to generate fake proofs. And this is because it is performed as a multy-party computation, to reduce the risks of the process distributing it in multiple participants.

In turn, each party takes the previous contribution (starting from an initial one generated during the creation of the ceremony) and contributes with a random input to generate entropy at the output. Then, the result of the process is uploaded and the toxic-waste is discarded. 

The process can be repeated through the participants in rounds until the ceremony ends (the number of rounds is determined during the ceremony creation process).

You can read more about trusted zk ceremonies [here](https://zkproof.org/2021/06/30/setup-ceremonies/).

## How to use the toolkit?

 - [Requirements](#requirements)
 - [Contribute to a ceremony](#contribute-to-a-ceremony)
 - [Create a new zk-ceremony](#create-a-new-zk-ceremony)

### Requirements 

* **Git and a Github account** with permissions push to non main branches of this repository. The process will be stored and tracked in a branch of the current GitHub repository. A verified signature must be configured with git to sign the resulting commits.
* **Git LFS installed and initialized** to track large files like contribution files.
* **Docker**: The toolkit uses docker containers to avoid installing dependencies on the host machine and to avoid incompatibilities.
* **Makefile**: As a CLI. It performs some checks such as if the previous dependencies are available or if the user have the correct environment in every process stage. 

### Contribute to a ceremony

**A.** Clone the repository and checkout the branch with the name of the desired ceremony:
```sh
git clone git@github.com:vocdoni/zk-voceremony.git
cd zk-voceremony
git checkout {CEREMONY_BRANCH}
```

**B.** Init the contribution and follow the instructions:
```sh
make contribute
```
This will create:
 * `{CONTRIBUTIONS_PATH}/{circuite_name}_{contributor_alias}.zkey`: The result of your contribution.

And will update:
 * `{CONTRIBUTIONS_PATH}/CONTRIBUTIONS.md`: Add your contribution filename and checksum to the list of contributions and set it as the last contribution.

### Create a new zk-ceremony
**A.** Run the following command to prepare the environment:
```sh
make env
```
This will create the `ceremony.env` following the `example.env` template, asking to you the required inputs. Then it will copy from your filesystem into the repo:
 * `{INPUTS_PATH}/{circuite_name}.circom`: the circom circuit file target of the ceremony
 * `{INPUTS_PATH}/{initial_ptau}.ptau`: the initial ptau file

It also will create the ceremony branch, commit and push these files to this branch.

A Github action will compile the circuit and generate the first contribution in the `{ceremony_name}` branch. This Github will also create an Pull Request assigned to you. If this PR is closed by you (without merge it), another Github action will be triggered that will finish the ceremony and generate the final artifacts.

## Troubleshooting

### `make contribute` fails with `git: 'lfs' is not a git command. See 'git --help'.`

You need **Git LFS installed and initialized**, get it at https://git-lfs.com/
    
### `make contribute` fails with `Commits must have valid signatures`

If you get this:
```
remote: error: GH006: Protected branch update failed for refs/heads/testing-ceremony.
remote: error: Commits must have valid signatures.
To github.com:vocdoni/zk-voceremony.git
 ! [remote rejected] testing-ceremony -> testing-ceremony (protected branch hook declined)
error: failed to push some refs to 'github.com:vocdoni/zk-voceremony.git'
make: *** [Makefile:68: push-contribution] Error 1
```
You need to configure Git to [sign your commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)

Also note that you'll need to discard your unsigned commit by doing
```
git reset --hard origin/$(git branch --show-current)
```
