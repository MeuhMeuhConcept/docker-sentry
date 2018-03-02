.PHONY: help sentry-upgrade sentry-user
.DEFAULT_GOAL := help

docker-compose.yml:
	cp docker-compose.yml.dist $@

.env:
	cp .env.dist $@
	docker run \
		--rm \
		sentry \
		config generate-secret-key | sed -r 's/(.*)/SENTRY_SECRET_KEY=\1/g' >> $@

sentry-upgrade: .env ## Upgrade sentry if database is new
	docker exec \
		--interactive \
		--tty \
		sentry-sentry \
		sentry upgrade

sentry-user: .env ## Configuring initial user
	docker exec \
		--interactive \
		--tty \
		sentry-sentry \
		sentry createuser

install: .env docker-compose.yml ## Install project, create env files

start: install ## Run the containers
	docker-compose up -d

stop: install ## Stop the containers
	docker-compose stop

help:
	@grep -E '^[a-zA-Z_-.]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
