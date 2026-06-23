.PHONY: help install upgrade rollback cleanup test lint validate

NAMESPACE := devops-app
RELEASE := devops-app
CHART := helm-chart

help:
	@echo "📚 Available commands:"
	@echo "  make install          - Install the Helm chart"
	@echo "  make upgrade          - Upgrade the Helm release"
	@echo "  make rollback         - Rollback to previous release"
	@echo "  make cleanup          - Delete the Helm release and namespace"
	@echo "  make test             - Run integration tests"
	@echo "  make lint             - Lint the Helm chart"
	@echo "  make validate         - Validate the chart"
	@echo "  make status           - Show release status"
	@echo "  make logs-api         - Tail API logs"
	@echo "  make logs-db          - Tail Database logs"
	@echo "  make logs-cache       - Tail Cache logs"
	@echo "  make port-forward     - Port-forward to API"
	@echo "  make describe-pods    - Describe all pods"
	@echo "  make install-staging  - Install with staging values"
	@echo "  make install-prod     - Install with production values"

lint:
	helm lint $(CHART)

validate:
	helm template $(RELEASE) $(CHART) | kubectl apply -f - --dry-run=client

install:
	cd scripts && ./install.sh

upgrade:
	cd scripts && ./upgrade.sh

rollback:
	cd scripts && ./rollback.sh

cleanup:
	cd scripts && ./cleanup.sh

test:
	cd scripts && ./test-deployment.sh

status:
	helm status $(RELEASE) -n $(NAMESPACE)

logs-api:
	kubectl logs -f deployment/$(RELEASE)-api -n $(NAMESPACE)

logs-db:
	kubectl logs -f deployment/$(RELEASE)-postgres -n $(NAMESPACE)

logs-cache:
	kubectl logs -f deployment/$(RELEASE)-redis -n $(NAMESPACE)

port-forward:
	kubectl port-forward svc/api-service 8080:80 -n $(NAMESPACE)

describe-pods:
	kubectl describe pods -n $(NAMESPACE)

install-staging:
	helm install $(RELEASE) $(CHART) -f $(CHART)/values-staging.yaml -n devops-staging --create-namespace

install-prod:
	helm install $(RELEASE) $(CHART) -f $(CHART)/values-prod.yaml -n devops-prod --create-namespace

history:
	helm history $(RELEASE) -n $(NAMESPACE)

get-values:
	helm get values $(RELEASE) -n $(NAMESPACE)

diff:
	helm diff upgrade $(RELEASE) $(CHART) -n $(NAMESPACE) || true

debug:
	helm install $(RELEASE) $(CHART) -n $(NAMESPACE) --dry-run --debug
