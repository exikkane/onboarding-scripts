.PHONY: bootstrap onboarding init init-light up down build serve migrate clearcache hooks-install

bootstrap:
	bash scripts/dev-bootstrap.sh

onboarding:
	bash scripts/onboarding-install.sh --shared --project "$(CURDIR)" --skills

init:
	CLIENT_INIT_MODE="$(mode)" bash scripts/client-init.sh "$(domain)"

init-light:
	CLIENT_INIT_MODE=light bash scripts/client-init.sh "$(domain)"

up:
	bash scripts/client-up.sh

down:
	bash scripts/client-down.sh

build:
	sudo docker compose config -q && \
	sudo docker compose build --pull

reboot:
	make down && make up

rebuild:
	make down && make build && make up

hooks-install:
	bash scripts/hooks-install.sh
