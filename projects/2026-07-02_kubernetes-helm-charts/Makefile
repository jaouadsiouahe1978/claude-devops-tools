.PHONY: help build push deploy-dev deploy-prod lint test clean

help:
	@echo "Kubernetes Helm Charts - Multi-Environment Deployment"
	@echo ""
	@echo "Available targets:"
	@echo "  build        - Build Docker image locally"
	@echo "  push         - Push Docker image to registry"
	@echo "  lint         - Lint Helm chart"
	@echo "  template     - Generate K8s YAML from templates"
	@echo "  deploy-dev   - Deploy to dev environment"
	@echo "  deploy-prod  - Deploy to prod environment"
	@echo "  upgrade-dev  - Upgrade dev deployment"
	@echo "  upgrade-prod - Upgrade prod deployment"
	@echo "  delete-dev   - Delete dev deployment"
	@echo "  delete-prod  - Delete prod deployment"
	@echo "  status       - Show deployment status"
	@echo "  logs         - Tail logs from pods"
	@echo "  test         - Run Flask app tests"
	@echo "  clean        - Clean up Docker images"

DOCKER_REGISTRY ?= my-registry
DOCKER_IMAGE ?= $(DOCKER_REGISTRY)/my-app
DOCKER_TAG ?= 1.0.0
HELM_RELEASE ?= my-app
KUBE_NAMESPACE_DEV ?= dev
KUBE_NAMESPACE_PROD ?= prod

build:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) python-app/
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG)-dev python-app/

push:
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)-dev

lint:
	helm lint helm-chart/my-app/
	helm lint helm-chart/my-app/ --strict

template:
	@echo "=== DEV Environment ===" && \
	helm template $(HELM_RELEASE) helm-chart/my-app/ -f helm-chart/my-app/values-dev.yaml -n $(KUBE_NAMESPACE_DEV)
	@echo "" && \
	echo "=== PROD Environment ===" && \
	helm template $(HELM_RELEASE) helm-chart/my-app/ -f helm-chart/my-app/values-prod.yaml -n $(KUBE_NAMESPACE_PROD)

deploy-dev:
	kubectl create namespace $(KUBE_NAMESPACE_DEV) --dry-run=client -o yaml | kubectl apply -f -
	helm install $(HELM_RELEASE) helm-chart/my-app/ \
		-f helm-chart/my-app/values-dev.yaml \
		-n $(KUBE_NAMESPACE_DEV)

deploy-prod:
	kubectl create namespace $(KUBE_NAMESPACE_PROD) --dry-run=client -o yaml | kubectl apply -f -
	helm install $(HELM_RELEASE) helm-chart/my-app/ \
		-f helm-chart/my-app/values-prod.yaml \
		-n $(KUBE_NAMESPACE_PROD)

upgrade-dev:
	helm upgrade $(HELM_RELEASE) helm-chart/my-app/ \
		-f helm-chart/my-app/values-dev.yaml \
		-n $(KUBE_NAMESPACE_DEV)

upgrade-prod:
	helm upgrade $(HELM_RELEASE) helm-chart/my-app/ \
		-f helm-chart/my-app/values-prod.yaml \
		-n $(KUBE_NAMESPACE_PROD)

delete-dev:
	helm uninstall $(HELM_RELEASE) -n $(KUBE_NAMESPACE_DEV)
	kubectl delete namespace $(KUBE_NAMESPACE_DEV)

delete-prod:
	helm uninstall $(HELM_RELEASE) -n $(KUBE_NAMESPACE_PROD)
	kubectl delete namespace $(KUBE_NAMESPACE_PROD)

status:
	@echo "=== Dev Deployment ===" && \
	kubectl get all -n $(KUBE_NAMESPACE_DEV) && \
	echo "" && \
	echo "=== Prod Deployment ===" && \
	kubectl get all -n $(KUBE_NAMESPACE_PROD)

logs:
	@echo "Choose environment: dev or prod"
	@read env; \
	if [ "$$env" = "dev" ]; then \
		kubectl logs -f -l app.kubernetes.io/name=my-app -n $(KUBE_NAMESPACE_DEV); \
	elif [ "$$env" = "prod" ]; then \
		kubectl logs -f -l app.kubernetes.io/name=my-app -n $(KUBE_NAMESPACE_PROD); \
	fi

test:
	cd python-app && \
	pip install -r requirements.txt && \
	python -m pytest -v || python app.py

clean:
	docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) || true
	docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG)-dev || true
