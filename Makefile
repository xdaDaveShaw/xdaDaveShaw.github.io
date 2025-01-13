SHELL := /bin/bash

.PHONY: help bootstrap
help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m|%s\n", $$1, $$2}' \
        | column -t -s '|'

run: ## Run the website locally
	@./run.sh

update-bundle: ## Update the GH pages gem bundles
	@./update-bundle.sh