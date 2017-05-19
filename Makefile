.PHONY: help redis postgresql postfix sentry-port sentry-upgrade sentry-user sentry
.DEFAULT_GOAL := help

redis: ## Launch Redis container
	docker run \
		--detach \
		--name sentry-redis \
		--volume=$(shell pwd)/data/redis:/var/lib/redis:Z \
		--restart=always \
		redis \
		--loglevel warning

postgresql: ## Launch Postgresql container
	docker run \
		--detach \
		--name sentry-postgresql \
		--volume=$(shell pwd)/data/postgresql:/var/lib/postgresql:Z \
		--restart=always \
		--env-file=postgresql.env \
		sameersbn/postgresql:9.6-2

postgresql.env:
	cp postgresql.env.dist $@

postfix: ## Launch Postfix container
	docker run \
		--detach \
		--name sentry-postfix \
		--restart=always \
		--env-file=postfix.env \
		--publish=25 \
		catatnight/postfix

postfix.env:
	cp postfix.env.dist $@

sentry.secret: ## Generate sentry secret key
	docker run \
		--rm \
		sentry \
		config generate-secret-key | sed -r 's/(.*)/SENTRY_SECRET_KEY=\1/g' > $@

sentry.env:
	cp sentry.env.dist $@

sentry.port:
	cp sentry.port.dist $@

sentry-upgrade: sentry.secret sentry.env ## Upgrade sentry if database is new
	docker run \
		--interactive \
		--tty \
		--rm \
		--env-file=sentry.secret \
		--env-file=sentry.env \
		--link=sentry-postgresql:postgres \
		--link=sentry-redis:redis \
		sentry \
		upgrade

sentry-user: sentry.secret sentry.env ## Configuring initial user
	docker run \
		--interactive \
		--tty \
		--rm \
		--env-file=sentry.secret \
		--env-file=sentry.env \
		--link=sentry-postgresql:postgres \
		--link=sentry-redis:redis \
		sentry \
		createuser

sentry-worker:
	docker run \
		--detach \
		--name sentry-worker \
		--env-file=sentry.secret \
		--env-file=sentry.env \
		--link=sentry-postgresql:postgres \
		--link=sentry-redis:redis \
		--link=sentry-postfix:postfix \
		sentry \
		run worker

sentry-cron:
	docker run \
		--detach \
		--name sentry-cron \
		--env-file=sentry.secret \
		--env-file=sentry.env \
		--link=sentry-postgresql:postgres \
		--link=sentry-redis:redis \
		--link=sentry-postfix:postfix \
		sentry \
		run cron

sentry: sentry.secret sentry.env sentry.port ## Launch Sentry container
	docker run \
		--detach \
		--name sentry-sentry \
		--env-file=sentry.secret \
		--env-file=sentry.env \
		--link=sentry-postgresql:postgres \
		--link=sentry-redis:redis \
		--link=sentry-postfix:postfix \
		--publish $(shell cat sentry.port):9000 \
		sentry

install: postgresql.env postfix.env sentry.env sentry.port ## Install project, create env files

help:
	@grep -E '^[a-zA-Z_-.]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
