.PHONY: up down api mobile web test lint migrate

up:
	docker compose up -d

down:
	docker compose down

api:
	cd services/api && uvicorn app.main:app --reload

mobile:
	cd apps/mobile && flutter run

web:
	cd apps/web && npm run dev

test:
	cd services/api && pytest
	cd apps/mobile && flutter test
	cd apps/web && npm test

lint:
	cd services/api && ruff check . && mypy .
	cd apps/mobile && dart format --output=none --set-exit-if-changed . && flutter analyze
	cd apps/web && npm run lint

migrate:
	cd services/api && alembic upgrade head
