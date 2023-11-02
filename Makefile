check-create-dependencies:
ifeq (, $(wildcard ceremony.env ))
	$(error ceremony.env is required and is not found, copy example.env to ceremony.env and fill in the values)
else ifeq (, $(shell command -v docker))
	$(error docker is required and is not installed)
else ifeq (, $(shell command -v git))
	$(error git is required and is not installed)
endif 

check-contribute-dependencies:
ifeq (,$(wildcard ./artifacts/*))
	$(error artifacts are required and are not found, are you sure that you are in the right branch?)
else ifeq (, $(wildcard CONTRIBUTIONS.md ))
	$(error the ceremony is not started, are you sure that you are in the right branch?)
else ifeq (, $(shell command -v docker))
	$(error docker is required and is not installed)
else ifeq (, $(shell command -v git))
	$(error git is required and is not installed)
endif

launch-creation: check-create-dependencies
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-creator-image -f ./dockerfiles/create-ceremony.dockerfile .
	@docker run --name zk-voceremony-creator -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-creator-image

launch-contribution: check-contribute-dependencies
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-contributor-image -f ./dockerfiles/contribute-ceremony.dockerfile .
	@docker run --name zk-voceremony-contributor -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-contributor-image

create: launch-creation
	$(info Cleaning up...)
	@docker rm zk-voceremony-creator -f -v
	@docker rmi zk-voceremony-creator-image -f

contribute: launch-contribution
	$(info Cleaning up...)
	@docker rm zk-voceremony-contributor -f -v > /dev/null
	@docker rmi zk-voceremony-contributor-image -f > /dev/null