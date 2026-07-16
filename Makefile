DSL_PATH ?= `pwd`/dsl
EXPORT_BASE ?= `pwd`/static-diagrams
STRUCTURIZR_WORKSPACE ?= 02-ai4eosc
EXPORT_FORMAT ?= static
# static --> HTML
# More options: https://docs.structurizr.com/export

# Create the specific export directory variable
EXPORT_PATH = $(EXPORT_BASE)/$(EXPORT_FORMAT)

ifndef VERBOSE
.SILENT:
endif

all: docker-pull run

.PHONY: help
help:
	@echo 'Makefile to generate the C4 Model architecutre using Structurizr       '
	@echo 'Usage:                                                                 '
	@echo '   make docker-pull        get Docker container                        '
	@echo '   make run                execute Structurizr local                   '
	@echo '   make generate-static    generate static diagrams                    '
	@echo '                                                                       '
	@echo 'Environment variables:                                                 '
	@echo ' DSLPATH: path for the DSL files (defaults to ./dsl)                   '

.PHONY: docker-pull
docker-pull:
	docker pull structurizr/structurizr

.PHONY: run
run:
	docker run -it --rm \
		-p 8080:8080 \
		-u $(id -u):$(id -g) \
		-v $(DSL_PATH):/usr/local/structurizr \
		-e STRUCTURIZR_WORKSPACES=* \
		structurizr/structurizr local

.PHONY: validate
validate:
	docker run -it --rm \
		-p 8080:8080 \
		-u $(id -u):$(id -g) \
		-v $(DSL_PATH):/usr/local/structurizr \
		structurizr/structurizr validate \
		-workspace /usr/local/structurizr/$(STRUCTURIZR_WORKSPACE)/workspace.dsl \

.PHONY: generate-static
generate-static:
	mkdir -p $(EXPORT_PATH)
	docker run -it --rm \
		-u $(shell id -u):$(shell id -g) \
		-v $(DSL_PATH):/usr/local/structurizr \
		-v $(EXPORT_PATH):/usr/local/structurizr/export \
		structurizr/structurizr export \
		-format $(EXPORT_FORMAT) \
		-workspace /usr/local/structurizr/$(STRUCTURIZR_WORKSPACE)/workspace.dsl \
		-output /usr/local/structurizr/export

.PHONY: push
push:
	$(MAKE) generate-static EXPORT_FORMAT=json EXPORT_PATH=$(DSL_PATH)/$(STRUCTURIZR_WORKSPACE)
	curl -v -X PUT \
	     -u "$(BASIC_AUTH_USER):$(BASIC_AUTH_PASS)" \
	     -H "Content-Type: application/json; charset=UTF-8" \
	     -T $(DSL_PATH)/$(STRUCTURIZR_WORKSPACE)/workspace.json \
	     https://structurizr.k8s.cloud.ai4eosc.eu/api/workspace/1

# "structurizr push" command from Docker image does not work from scratch because
# the instance is behind BasicAuth credentials. So we have to push using the API
# directly instead