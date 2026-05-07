.PHONY: help build push deploy-dev deploy-prod logs clean docker-up docker-down

help:
	@echo "Available targets:"
	@echo "  make build           - Build Docker images locally"
	@echo "  make push            - Push images to registry (requires configured registry)"
	@echo "  make deploy-dev      - Deploy to dev environment"
	@echo "  make deploy-prod     - Deploy to prod environment"
	@echo "  make logs            - Show logs from all pods"
	@echo "  make status          - Show cluster status"
	@echo "  make clean           - Clean up deployments"
	@echo "  make docker-up       - Start Minikube"
	@echo "  make docker-down     - Stop Minikube"

# Docker build targets
build: build-api build-frontend
	@echo "✓ All images built"

build-api:
	@echo "Building API image..."
	docker build -t my-api:1.0 ./app/api
	@echo "✓ API image built"

build-frontend:
	@echo "Building Frontend image..."
	docker build -t my-frontend:1.0 ./app/frontend
	@echo "✓ Frontend image built"

# Docker push (for registry deployment)
push: push-api push-frontend
	@echo "✓ All images pushed"

push-api: build-api
	@echo "Pushing API image..."
	docker tag my-api:1.0 $(REGISTRY)/my-api:1.0
	docker push $(REGISTRY)/my-api:1.0

push-frontend: build-frontend
	@echo "Pushing Frontend image..."
	docker tag my-frontend:1.0 $(REGISTRY)/my-frontend:1.0
	docker push $(REGISTRY)/my-frontend:1.0

# Kubernetes deployment
deploy-dev: build
	@echo "Deploying to dev environment..."
	kubectl apply -k k8s/overlays/dev
	@echo "✓ Dev deployment applied"
	@echo "Waiting for deployment..."
	kubectl rollout status deployment/dev-api -n myapp-dev
	kubectl rollout status deployment/dev-frontend -n myapp-dev

deploy-prod: build
	@echo "Deploying to prod environment..."
	kubectl apply -k k8s/overlays/prod
	@echo "✓ Prod deployment applied"
	@echo "Waiting for deployment..."
	kubectl rollout status deployment/prod-api -n myapp-prod
	kubectl rollout status deployment/prod-frontend -n myapp-prod

# Status and debugging
status:
	@echo "=== Cluster Status ==="
	kubectl cluster-info
	@echo "\n=== Deployments ==="
	kubectl get deployments -A
	@echo "\n=== Services ==="
	kubectl get services -A
	@echo "\n=== Ingress ==="
	kubectl get ingress -A
	@echo "\n=== Pods ==="
	kubectl get pods -A

logs:
	@echo "=== API Logs ==="
	kubectl logs -f deployment/api -n myapp --tail=50 2>/dev/null || echo "Dev deployment not found"

logs-prod:
	@echo "=== API Logs (Prod) ==="
	kubectl logs -f deployment/prod-api -n myapp-prod --tail=50 2>/dev/null || echo "Prod deployment not found"

# Port forwarding
port-forward-api:
	@echo "Forwarding API to localhost:5000..."
	kubectl port-forward svc/api 5000:80 -n myapp

port-forward-frontend:
	@echo "Forwarding Frontend to localhost:3000..."
	kubectl port-forward svc/frontend 3000:80 -n myapp

# Testing
test-api:
	@echo "Testing API endpoints..."
	@curl -s http://localhost:5000/api/status | jq . || echo "Failed to connect"

test-frontend:
	@echo "Testing Frontend..."
	@curl -s http://localhost:3000 | head -20

# Cleanup
clean:
	@echo "Cleaning up dev environment..."
	kubectl delete -k k8s/overlays/dev 2>/dev/null || true
	@echo "Cleaning up prod environment..."
	kubectl delete -k k8s/overlays/prod 2>/dev/null || true
	@echo "✓ Cleanup complete"

# Minikube helpers
docker-up:
	@echo "Starting Minikube..."
	minikube start
	@echo "Enabling addons..."
	minikube addons enable ingress
	minikube addons enable metrics-server
	@echo "✓ Minikube started"
	@echo "Dashboard: minikube dashboard"

docker-down:
	@echo "Stopping Minikube..."
	minikube stop
	@echo "✓ Minikube stopped"

# Validation
validate:
	@echo "Validating Kubernetes manifests..."
	kubectl kustomize k8s/overlays/dev 2>/dev/null > /dev/null && echo "✓ Dev kustomization valid" || echo "✗ Dev kustomization invalid"
	kubectl kustomize k8s/overlays/prod 2>/dev/null > /dev/null && echo "✓ Prod kustomization valid" || echo "✗ Prod kustomization invalid"
