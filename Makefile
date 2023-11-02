-include ceremony.env

CURRENT_BRANCH := $(shell git branch --show-current)

global_checks:
ifeq (, $(wildcard ceremony.env ))
	$(error ceremony.env is required and is not found, copy example.env to ceremony.env and fill in the values)
else ifeq (, $(shell command -v docker))
	$(error docker is required and is not installed)
else ifeq (, $(shell command -v git))
	$(error git is required and is not installed)
else ifeq ($(CURRENT_BRANCH), main)
	$(error You are on the main branch, please switch to a ceremony branch)
endif
ifeq ($(CURRENT_BRANCH), $(CEREMONY_BRANCH))
else 
	$(error You are not on the ceremony branch, please switch to $(CEREMONY_BRANCH) branch)
endif

check-contribute-dependencies:
ifeq (,$(wildcard ./artifacts/*))
	$(error artifacts are required and are not found, are you sure that you are in the right branch?)
else ifeq (, $(wildcard CONTRIBUTIONS.md ))
	$(error the ceremony is not started, are you sure that you are in the right branch?)
endif

launch-creation: global_checks
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-creator-image -f ./dockerfiles/create-ceremony.dockerfile .
ifeq ($(unattended), true)
	@docker run --rm --name zk-voceremony-creator -q -v ./:/app --env-file ./ceremony.env zk-voceremony-creator-image  bash ./scripts/create-ceremony.sh -y
else
	@docker run --rm --name zk-voceremony-creator -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-creator-image
endif

launch-contribution: global_checks check-contribute-dependencies
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-contributor-image -f ./dockerfiles/contribute-ceremony.dockerfile .
	@docker run --rm --name zk-voceremony-contributor -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-contributor-image

create: launch-creation
	$(info Cleaning up...)
	@docker rmi zk-voceremony-creator-image -f

contribute: launch-contribution
	$(info Cleaning up...)
	@docker rmi zk-voceremony-contributor-image -f