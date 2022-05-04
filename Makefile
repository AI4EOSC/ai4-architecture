DSLPATH ?= `pwd`/dsl
STRUCTURIZR_WORKSPACE_PATH ?= ai4eosc

ifndef VERBOSE
.SILENT:
endif

all: docker-pull run

.PHONY: help
help: 
	@echo 'Makefile to generate the C4 Model architecutre using Structurizr       ' 
	@echo 'Usage:                                                                 ' 
	@echo '   make docker-pull get Docker container                               ' 
	@echo '   make run         execute Structurizr lite                           ' 
	@echo '                                                                       ' 
	@echo 'Environment variables:                                                 ' 
	@echo ' DSLPATH: path for the DSL files (defaults to ./dsl)                   '

.PHONY: docker-pull
docker-pull:
	docker pull structurizr/lite

.PHONY: run
run:
	docker run -it --rm -p 8080:8080 -v $(DSLPATH):/usr/local/structurizr -e STRUCTURIZR_WORKSPACE_PATH=$(STRUCTURIZR_WORKSPACE_PATH) structurizr/lite 
