.PHONY: help install uninstall create-apps sync status logs dashboard clean

ARGOCD_NS := argocd

help:
	@echo "ArgoCD GitOps - Commandes utiles"
	@echo ""
	@echo "Installation:"
	@echo "  make install          - Installer ArgoCD"
	@echo "  make create-kind      - Créer un cluster Kind"
	@echo ""
	@echo "Applications:"
	@echo "  make create-apps      - Déployer les applications"
	@echo "  make sync             - Synchroniser les apps"
	@echo "  make status           - Voir le statut"
	@echo ""
	@echo "Interface:"
	@echo "  make dashboard        - Ouvrir le dashboard"
	@echo "  make port-forward     - Port-forward"
	@echo ""
	@echo "Maintenance:"
	@echo "  make uninstall        - Désinstaller ArgoCD"
	@echo "  make clean            - Nettoyer"

install:
	@echo "Installation d'ArgoCD..."
	./argocd-install.sh

uninstall:
	@echo "Désinstallation..."
	kubectl delete namespace $(ARGOCD_NS) --ignore-not-found

create-kind:
	kind create cluster --config kind-config.yaml

create-apps:
	@echo "Déploiement des applications..."
	kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -f application-example.yaml

sync:
	argocd app sync -l argocd.argoproj.io/instance || \
	kubectl get applications -n $(ARGOCD_NS) -o json | \
	jq -r '.items[].metadata.name' | \
	xargs -I {} argocd app sync {}

status:
	@echo "Statut des applications:"
	@kubectl get applications -n $(ARGOCD_NS)

watch-status:
	watch -n 5 'kubectl get applications -n $(ARGOCD_NS)'

logs:
	kubectl logs -n $(ARGOCD_NS) -l app.kubernetes.io/name=argocd-application-controller -f

dashboard:
	@echo "Dashboard ArgoCD: https://localhost:8080"
	@kubectl -n $(ARGOCD_NS) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""

port-forward:
	kubectl port-forward svc/argocd-server -n $(ARGOCD_NS) 8080:443

info:
	@echo "=== Informations ArgoCD ==="
	@kubectl get pods -n $(ARGOCD_NS)

validate-helm:
	helm lint helm-app/

quickstart: create-kind install create-apps status
	@echo "✓ QuickStart complète!"

clean:
	pkill -f "kubectl port-forward" || true

.DEFAULT_GOAL := help
