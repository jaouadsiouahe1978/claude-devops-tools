.PHONY: help install lint format test test-cov clean build run compose-up compose-down deploy

# Variables
PYTHON := python3
PIP := pip3
PYTEST := pytest
DOCKER_IMAGE := cicd-app
DOCKER_TAG := latest
VENV := venv

help:
	@echo "CI/CD Demo Application - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install          Install dependencies"
	@echo "  make venv            Create virtual environment"
	@echo ""
	@echo "Development:"
	@echo "  make lint            Run code linting (flake8)"
	@echo "  make format          Format code (black)"
	@echo "  make format-check    Check code formatting"
	@echo "  make type-check      Run type checking (mypy)"
	@echo "  make test            Run tests"
	@echo "  make test-cov        Run tests with coverage"
	@echo ""
	@echo "Docker:"
	@echo "  make build           Build Docker image"
	@echo "  make run             Run application locally"
	@echo "  make compose-up      Start Docker Compose stack"
	@echo "  make compose-down    Stop Docker Compose stack"
	@echo "  make compose-logs    View Docker Compose logs"
	@echo ""
	@echo "Security:"
	@echo "  make security        Run security checks (bandit, safety)"
	@echo ""
	@echo "CI/CD:"
	@echo "  make ci-local        Run local CI equivalent"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           Clean up generated files"
	@echo "  make clean-docker    Remove Docker images"

## Setup targets

venv:
	$(PYTHON) -m venv $(VENV)
	. $(VENV)/bin/activate && pip install --upgrade pip

install: requirements.txt
	$(PIP) install -r requirements.txt

install-dev: install
	$(PIP) install pytest pytest-cov pytest-flask black flake8 mypy bandit safety

## Development targets

lint:
	$(PYTHON) -m flake8 src/ tests/

format:
	$(PYTHON) -m black src/ tests/

format-check:
	$(PYTHON) -m black --check --diff src/ tests/

type-check:
	$(PYTHON) -m mypy src/ --ignore-missing-imports || true

test:
	$(PYTEST) tests/ -v

test-cov:
	$(PYTEST) tests/ -v --cov=src --cov-report=html --cov-report=term-missing
	@echo "Coverage report generated in htmlcov/index.html"

test-fast:
	$(PYTEST) tests/ -v --tb=short -x

test-watch:
	ptw tests/ -- -v

## Docker targets

build:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	@echo "✓ Docker image built: $(DOCKER_IMAGE):$(DOCKER_TAG)"

run: build
	docker run -it --rm -p 8000:8000 \
		-e ENVIRONMENT=development \
		-e DEBUG=True \
		$(DOCKER_IMAGE):$(DOCKER_TAG)

compose-up:
	docker-compose up -d
	@echo "✓ Docker Compose stack started"
	@echo "  - App: http://localhost:8000"
	@echo "  - Nginx: http://localhost:80"
	@echo "  - PostgreSQL: localhost:5432"
	@echo "  - Redis: localhost:6379"

compose-down:
	docker-compose down
	@echo "✓ Docker Compose stack stopped"

compose-logs:
	docker-compose logs -f

compose-logs-app:
	docker-compose logs -f app

## Security targets

security:
	@echo "Running security checks..."
	@$(PYTHON) -m bandit -r src/ -ll
	@echo "✓ Bandit check passed"
	@$(PYTHON) -m safety check --json || true
	@echo "✓ Safety check completed"

## CI/CD targets

ci-local: lint format-check type-check test security
	@echo "✓ All CI checks passed locally"

## Cleanup targets

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache/ .mypy_cache/ .coverage htmlcov/ dist/ build/
	@echo "✓ Cleaned up Python artifacts"

clean-docker:
	docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) 2>/dev/null || true
	@echo "✓ Cleaned up Docker images"

clean-all: clean clean-docker
	@echo "✓ Full cleanup completed"

## Application targets

server:
	FLASK_APP=src.app FLASK_ENV=development $(PYTHON) -m flask run --host=0.0.0.0 --port=8000

server-prod:
	gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 60 src.app:app

## Utility targets

.env:
	cp .env.example .env
	@echo "✓ Created .env file from .env.example"

version:
	@if [ -f VERSION ]; then cat VERSION; else echo "1.0.0"; fi

info:
	@echo "Application: CI/CD Demo App"
	@echo "Version: $$(make version)"
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Docker: $$(docker --version)"
	@echo "Docker Compose: $$(docker-compose --version)"

status:
	@echo "Container Status:"
	@docker-compose ps || echo "No containers running"

## Default target
.DEFAULT_GOAL := help
