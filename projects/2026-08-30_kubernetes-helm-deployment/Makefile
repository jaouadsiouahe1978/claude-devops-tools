.PHONY: help build deploy-dev deploy-prod test-dev test-prod clean

help:
	@echo "Kubernetes Helm Deployment - Available Commands"
	@echo ""
	@echo "  make build         - Build Docker image"
	@echo "  make deploy-dev    - Deploy to development"
	@echo "  make deploy-prod   - Deploy to production"
	@echo "  make test-dev      - Test dev deployment"
	@echo "  make test-prod     - Test prod deployment"
	@echo "  make clean         - Clean all deployments"

build:
	@chmod +x scripts/build.sh
	@scripts/build.sh

deploy-dev: build
	@chmod +x scripts/deploy.sh
	@scripts/deploy.sh dev

deploy-prod: build
	@chmod +x scripts/deploy.sh
	@scripts/deploy.sh prod

test-dev:
	@chmod +x scripts/test.sh
	@scripts/test.sh dev

test-prod:
	@chmod +x scripts/test.sh
	@scripts/test.sh prod

clean:
	helm uninstall myapp-dev -n dev 2>/dev/null || true
	helm uninstall myapp-prod -n prod 2>/dev/null || true
	kubectl delete ns dev prod 2>/dev/null || true
