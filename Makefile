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

create: check-create-dependencies
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-creator -f ./dockerfiles/create-ceremony.dockerfile .
	@docker run -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-creator

contribute: check-contribute-dependencies
	$(info Starting docker container...)
	@docker build -q -t zk-voceremony-contributor -f ./dockerfiles/contribute-ceremony.dockerfile .
	@docker run -qit -v ./:/app --env-file ./ceremony.env zk-voceremony-contributor