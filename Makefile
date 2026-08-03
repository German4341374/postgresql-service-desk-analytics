SHELL := /bin/bash

.PHONY: setup up wait migrate seed optimize refresh query-smoke smoke test benchmark backup restore deadlock down clean

setup:
	@test -f .env || cp .env.example .env
	$(MAKE) up
	$(MAKE) wait
	$(MAKE) migrate
	$(MAKE) seed
	$(MAKE) optimize
	$(MAKE) refresh
	$(MAKE) smoke

up:
	docker compose up --detach

wait:
	bash scripts/wait-for-postgres.sh

migrate:
	bash scripts/migrate.sh

seed:
	bash scripts/seed.sh

optimize:
	bash scripts/apply-optimizations.sh

refresh:
	bash scripts/refresh-materialized-views.sh

query-smoke:
	bash scripts/query-smoke.sh

smoke:
	bash scripts/smoke-test.sh

test: smoke query-smoke
	bash scripts/backup-restore-demo.sh
	bash scripts/deadlock-demo.sh

benchmark:
	bash scripts/benchmark.sh

backup:
	bash scripts/backup.sh

restore:
	bash scripts/restore.sh $${BACKUP_FILE:?Set BACKUP_FILE to a .dump path}

deadlock:
	bash scripts/deadlock-demo.sh

down:
	docker compose down

clean:
	docker compose down --volumes --remove-orphans
	rm -rf backups/* optimization/results/generated
