.PHONY: up down build logs shell wp health

up:
	docker compose up -d --build

down:
	docker compose down

build:
	docker compose build --no-cache

logs:
	docker compose logs -f app

shell:
	docker compose exec app sh

wp:
	docker compose --profile tools run --rm wp-cli

health:
	./scripts/healthcheck.sh
