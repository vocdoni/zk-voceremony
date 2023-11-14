-include ceremony.env

CURRENT_BRANCH := $(shell git branch --show-current)

global-checks:
ifeq (, $(shell command -v docker))
	$(error docker is required and is not installed)
else ifeq (, $(shell command -v git))
	$(error git is required and is not installed)
else ifeq (, $(shell command -v git lfs))
	$(error git lfs is required and is not installed. Once installed, run 'git lfs install')
endif

on-going-ceremony-check:
ifeq (, $(wildcard ceremony.env ))
	$(error ceremony.env is required and is not found, copy example.env to ceremony.env and fill in the values)
else ifeq ($(CURRENT_BRANCH), main)
	$(error You are on the main branch, please switch to a ceremony branch)
endif

ifeq ($(CURRENT_BRANCH), $(CEREMONY_BRANCH))
else 
	$(error You are not on the ceremony branch, please switch to $(CEREMONY_BRANCH) branch)
endif

check-contribute-dependencies:
ifeq (,$(wildcard $(CONTRIBUTIONS_PATH)/*))
	$(error artifacts are required and are not found, are you sure that you are in the right branch?)
else ifeq (, $(wildcard $(CONTRIBUTIONS_PATH)/CONTRIBUTIONS.md ))
	$(error the ceremony is not started, are you sure that you are in the right branch?)
endif

launch-creation:
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-creator-image -f ./dockerfiles/create-ceremony.dockerfile .
ifeq ($(unattended), true)
	@docker run --rm --name zk-voceremony-creator -q -v ./:/app --env-file ./ceremony.env zk-voceremony-creator-image  bash ./scripts/create-ceremony.sh -y
else
	@docker run --rm --name zk-voceremony-creator -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-creator-image
endif

push-creation:
	$(info Pushing changes...)
	@git add $(TARGET_CIRCUIT) $(INPUT_PTAU) ceremony.env
	@git commit -m "Init '$(CEREMONY_BRANCH)' ceremony"
	@git push origin $(CEREMONY_BRANCH)

clean-creation:
	$(info Cleaning up...)
	@docker rmi zk-voceremony-creator-image -f

verify-last-contribution:
	@docker build -q -t zk-voceremony-verifier-image -f ./dockerfiles/verify-contribution.dockerfile .
	@docker run --rm --name zk-voceremony-verifier -qt --env-file ./ceremony.env zk-voceremony-verifier-image

clean-last-verify:
	$(info Cleaning up...)
	@docker rmi zk-voceremony-verifier-image -f

launch-finish-ceremony:
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-finisher-image -f ./dockerfiles/finish-ceremony.dockerfile .
	@docker run --rm --name zk-voceremony-finisher -qt -v ./:/app --env-file ./ceremony.env zk-voceremony-finisher-image

clean-finish-ceremony:
	$(info Cleaning up...)
	@docker rmi zk-voceremony-finisher-image -f

push-finish-ceremony:
	$(info Pushing changes...)
	@git add $(OUTPUT_PATH)/RESULTS.md $(OUTPUT_PATH)/*.zkey $(OUTPUT_PATH)/*.json $(OUTPUT_PATH)/*.wasm
	@git commit -m "Finish '$(CEREMONY_BRANCH)' ceremony"
	@git push origin $(CEREMONY_BRANCH)

env: global-checks 
	@sh ./scripts/create-env.sh
	$(info Done! Check the process in github action report and checkout the results in $(CEREMONY_BRANCH).)

create-locally: global-checks on-going-ceremony-check launch-creation clean-creation
	$(info Done!)

finish: global-checks on-going-ceremony-check launch-finish-ceremony clean-finish-ceremony push-finish-ceremony
	$(info Done!)

verify-locally: global-checks on-going-ceremony-check verify-last-contribution clean-last-verify
	$(info Done!)

finish-locally: global-checks on-going-ceremony-check launch-finish-ceremony clean-finish-ceremony
	$(info Done!)