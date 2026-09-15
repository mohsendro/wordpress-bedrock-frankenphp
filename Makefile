.PHONY: bootstrap up down restart build logs shell wp health composer lock backup

bootstrap:
	./scripts/bootstrap.sh

up:
	./scripts/compose.sh up -d --build --wait

down:
	./scripts/compose.sh down

restart:
	./scripts/compose.sh up -d --build --force-recreate --wait

build:
	./scripts/compose.sh build --no-cache

logs:
	./scripts/compose.sh logs -f app

shell:
	./scripts/compose.sh exec app sh

wp:
	./scripts/compose.sh --profile tools run --rm wp-cli

composer:
	./scripts/compose.sh run --rm --no-deps app composer

lock:
	composer update --no-interaction --prefer-dist --no-progress

backup:
	./scripts/backup-db.sh

health:
	./scripts/healthcheck.sh
