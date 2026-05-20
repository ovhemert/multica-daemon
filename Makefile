IMAGE    ?= multica-daemon
TAG      ?= dev
REGISTRY ?= ghcr.io/ovhemert/multica-daemon
export IMAGE TAG REGISTRY

.PHONY: help build run logs shell push clean
.DEFAULT_GOAL := help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:[^#]*## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":[^#]*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Build the development image (docker compose build)
	docker compose build

run: ## Start the daemon container in the background
	docker compose up -d

logs: ## Follow daemon logs (Ctrl-C to stop)
	docker compose logs -f daemon

shell: ## Open an interactive shell in the running daemon container
	docker compose exec daemon /bin/bash

push: ## Push all image variants to the registry (docker buildx bake --push)
	docker buildx bake --push

clean: ## Stop containers and remove volumes and orphaned services
	docker compose down --volumes --remove-orphans
