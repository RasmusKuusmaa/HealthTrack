.PHONY: up down api mobile web test lint migrate openapi

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

openapi:
	cd services/api && python scripts/export_openapi.py
	npx --yes @openapitools/openapi-generator-cli generate \
		-i packages/contracts/openapi.json \
		-g dart-dio \
		-o packages/contracts \
		--additional-properties=serializationLibrary=json_serializable,pubName=healthtrack_api_client
	cd packages/contracts && dart pub get && dart run build_runner build --delete-conflicting-outputs
