REGISTRY ?= ghcr.io/ovhemert/multica-daemon
COMPOSE_PROFILES ?= all
SERVICE ?= daemon-claude
export REGISTRY
export COMPOSE_PROFILES

.PHONY: help build run logs shell clean
.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:[^#]*## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":[^#]*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Build the development image (docker compose build)
	docker compose build

run: ## Start the daemon container in the background
	docker compose up -d

logs: ## Follow daemon logs (Ctrl-C to stop)
	docker compose logs -f

shell: ## Open an interactive shell in SERVICE (default: daemon-claude)
	docker compose exec $(SERVICE) /bin/bash

clean: ## Stop containers and remove volumes and orphaned services
	docker compose down --volumes --remove-orphans
