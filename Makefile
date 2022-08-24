.PHONY: help

help: ## *:･ﾟ✧*:･ﾟ✧ This help *:･ﾟ✧*:･ﾟ✧
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m[ \033[36m%-15s \033[33m]\033[0m  %s\n", $$1, $$2}'



service-up: ## Build and start SSH BOX service
	docker-compose up --build -d -t 1

service-logs: ## View logs
	docker-compose logs -f -t

service-dev: ## Build and start service, foreground
	docker-compose build
	docker-compose up --force-recreate -t 0
	#docker-compose logs -f -t

service-down: ## Shutdown
	docker-compose down -t 1

service-bash: ## Enter shell
	docker-compose exec ssh-ftp-server bash

service-update: ## Pull never image
	docker pull alpine:latest

user-update: ## Run user creation scripts
	docker-compose exec ssh-ftp-server update_users.sh

user-add:
	bash user-add


