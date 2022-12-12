# TTD: pass GIT_HASH to docker-compose


BASEURL ?= https://127.0.0.1.sslip.io
E2E_RUN = cd e2e; CYPRESS_BASE_URL=$(BASEURL)
# export
export GIT_HASH := $(shell git rev-parse --short HEAD)

pull: ## Pull most recent Docker container builds (nightlies)
	docker-compose pull

start: ## Start all Docker containers
	docker-compose up --detach

start-rebuild: ## Start all Docker containers, [re]building as needed
	docker-compose up --detach --build

stop: ## Stop all Docker containers
	docker-compose down

hash: ## Show current short hash
	@echo Git hash: ${GIT_HASH}

ENV_CONFIG = config/docker-dev-common.env
JS_CONFIG = config/polis.config.template.common.js
update-config: ## Copy common config files into docker directories
	cp -f ${ENV_CONFIG} math/docker-dev.env
	cp -f ${ENV_CONFIG} server/docker-db-dev.env
	cp -f ${ENV_CONFIG} server/docker-dev.env
	cp -f ${JS_CONFIG} client-admin/polis.config.template.js
	cp -f ${JS_CONFIG} client-participation/polis.config.template.js
	cp -f ${JS_CONFIG} client-report/polis.config.template.js

e2e-install: e2e/node_modules ## Install Cypress E2E testing tools
	$(E2E_RUN) npm install

e2e-prepare: ## Prepare to run Cypress E2E tests
	@# Testing embeds requires a override of a file prior to build.
	cp e2e/cypress/fixtures/html/embed.html client-admin/embed.html

e2e-run-minimal: ## Run E2E tests: minimal (smoke test)
	$(E2E_RUN) npm run e2e:minimal

e2e-run-standalone: ## Run E2E tests: standalone (no credentials required)
	$(E2E_RUN) npm run e2e:standalone

e2e-run-secret: ## Run E2E tests: secret (credentials required)
	$(E2E_RUN) npm run e2e:secret

e2e-run-subset: ## Run E2E tests: filter tests by TEST_FILTER envvar (without browser exit)
	$(E2E_RUN) npm run e2e:subset

e2e-run-all: ## Run E2E tests: all
	$(E2E_RUN) npm run e2e:all


# Helpful CLI shortcuts
rbs: start-rebuild


%:
	@true

.PHONY: help

help:
	@echo 'Usage: make <command>'
	@echo
	@echo 'where <command> is one of the following:'
	@echo
	@grep -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
