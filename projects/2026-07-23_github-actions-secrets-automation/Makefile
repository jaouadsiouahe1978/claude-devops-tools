.PHONY: help build test run clean

help:
	@echo "GitHub Actions - Secrets Management"
	@echo "Available: build test run clean lint security"

build:
	docker build -t github-actions-demo:latest .

test:
	python3 -m pytest src/tests/ -v --cov=src

run:
	ENVIRONMENT=development python3 src/app.py

run-docker:
	docker-compose up -d
	@echo "App running at http://localhost:5000"

clean:
	rm -rf build/ dist/ __pycache__ .pytest_cache .coverage
	docker-compose down

lint:
	black src/ && isort src/

security:
	@echo "Running security scans..."
	bandit -r src/ || true
	safety check || true
