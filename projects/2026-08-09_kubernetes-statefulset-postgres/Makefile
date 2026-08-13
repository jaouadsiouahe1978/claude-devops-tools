# Kubernetes StatefulSet PostgreSQL - Makefile
# Facilite l'execution des commandes courantes

NAMESPACE = postgresql
STATEFULSET = postgres
POD_0 = postgres-0

.PHONY: help deploy destroy logs test-persistence monitor insert-data check-data cleanup

help:
	@echo "📚 Kubernetes StatefulSet PostgreSQL - Commandes disponibles"
	@echo ""
	@echo "Déploiement:"
	@echo "  make deploy              - Déployer le StatefulSet complet"
	@echo "  make deploy-quick        - Déployer rapidement (skip readiness)"
	@echo ""
	@echo "Opérations:"
	@echo "  make insert-data         - Insérer des données de test"
	@echo "  make check-data          - Vérifier les données"
	@echo "  make test-persistence    - Test complet de persistance"
	@echo ""
	@echo "Monitoring:"
	@echo "  make monitor             - Monitor le StatefulSet en temps réel"
	@echo "  make logs                - Afficher les logs du pod postgres-0"
	@echo "  make logs-0              - Logs du pod postgres-0"
	@echo "  make logs-1              - Logs du pod postgres-1"
	@echo "  make shell               - Shell interactif sur postgres-0"
	@echo "  make psql                - Connexion psql interactive"
	@echo ""
	@echo "Inspection:"
	@echo "  make status              - État du StatefulSet"
	@echo "  make pods                - Liste des pods"
	@echo "  make pvc                 - Liste des PersistentVolumeClaims"
	@echo "  make pv                  - Liste des PersistentVolumes"
	@echo "  make services            - Liste des services"
	@echo "  make describe            - Description détaillée du StatefulSet"
	@echo ""
	@echo "Nettoyage:"
	@echo "  make destroy             - Supprimer le StatefulSet"
	@echo "  make cleanup             - Nettoyer toutes les ressources"
	@echo "  make cleanup-pv          - Supprimer les PersistentVolumes"
	@echo ""

# ============================================================================
# Déploiement
# ============================================================================

deploy: deploy-ns deploy-pv deploy-ss
	@echo "✅ Déploiement complet terminé!"

deploy-ns:
	@echo "1. Création du namespace et des ConfigMaps..."
	kubectl apply -f 1-namespace.yaml

deploy-pv:
	@echo "2. Création des PersistentVolumes..."
	kubectl apply -f 2-persistent-volumes.yaml

deploy-ss:
	@echo "3. Déploiement du StatefulSet PostgreSQL..."
	kubectl apply -f 3-statefulset-postgres.yaml
	@echo ""
	@echo "⏳ Attente du déploiement..."
	kubectl wait --for=condition=ready pod/$(POD_0) -n $(NAMESPACE) --timeout=300s 2>/dev/null || \
		echo "   (Pod pas encore prêt, continuez avec 'make logs' pour monitorer)"

deploy-quick:
	$(MAKE) deploy-ns
	$(MAKE) deploy-pv
	@echo "3. Déploiement rapide du StatefulSet..."
	kubectl apply -f 3-statefulset-postgres.yaml
	@echo "✅ Déploiement lancé (en mode rapide, sans attendre)"

# ============================================================================
# Données et tests
# ============================================================================

insert-data:
	@echo "📝 Insertion de données..."
	@bash scripts/insert-data.sh

check-data:
	@echo "🔍 Vérification des données..."
	@bash scripts/check-data.sh

test-persistence:
	@echo "🧪 Test de persistance..."
	bash scripts/test-persistence.sh

# ============================================================================
# Monitoring et inspection
# ============================================================================

monitor:
	@echo "👀 Monitoring du StatefulSet (Ctrl+C pour arrêter)..."
	bash scripts/monitor.sh

status:
	@echo "📊 État du StatefulSet:"
	@kubectl get statefulset -n $(NAMESPACE)
	@echo ""
	@echo "📊 État des pods:"
	@kubectl get pods -n $(NAMESPACE)

pods:
	@kubectl get pods -n $(NAMESPACE) -o wide

pods-watch:
	@kubectl get pods -n $(NAMESPACE) -o wide -w

pvc:
	@kubectl get pvc -n $(NAMESPACE)

pv:
	@kubectl get pv

services:
	@kubectl get svc -n $(NAMESPACE)

logs:
	@kubectl logs $(POD_0) -n $(NAMESPACE) -f

logs-0:
	@kubectl logs postgres-0 -n $(NAMESPACE) -f

logs-1:
	@kubectl logs postgres-1 -n $(NAMESPACE) -f

logs-all:
	@echo "Logs de postgres-0:"
	@kubectl logs postgres-0 -n $(NAMESPACE)
	@echo ""
	@echo "Logs de postgres-1:"
	@kubectl logs postgres-1 -n $(NAMESPACE)

describe:
	@kubectl describe statefulset $(STATEFULSET) -n $(NAMESPACE)

# ============================================================================
# Interactions interactives
# ============================================================================

shell:
	@echo "🐚 Shell interactif sur $(POD_0)..."
	@kubectl exec -it $(POD_0) -n $(NAMESPACE) -- /bin/sh

psql:
	@echo "🗄️  Connexion psql interactive..."
	@kubectl exec -it $(POD_0) -n $(NAMESPACE) -- psql -U postgres

bash-script:
	@echo "🔧 Exécution du test de persistance..."
	bash scripts/test-persistence.sh

# ============================================================================
# Nettoyage
# ============================================================================

destroy:
	@echo "🧹 Suppression du StatefulSet..."
	kubectl delete statefulset $(STATEFULSET) -n $(NAMESPACE) 2>/dev/null || true
	kubectl delete service postgres -n $(NAMESPACE) 2>/dev/null || true
	@echo "✅ StatefulSet supprimé!"

cleanup: destroy
	@echo "🧹 Nettoyage complet..."
	bash scripts/cleanup.sh

cleanup-pv:
	@echo "⚠️  Suppression des PersistentVolumes..."
	kubectl delete pv pv-0 pv-1 2>/dev/null || echo "   (PV introuvables)"

cleanup-all: cleanup cleanup-pv
	@echo "✅ Nettoyage complet terminé!"

# ============================================================================
# Commandes avancées
# ============================================================================

crash-pod:
	@echo "💥 Simulation d'un crash du pod $(POD_0)..."
	@kubectl delete pod $(POD_0) -n $(NAMESPACE)
	@echo "   Attente de la recréation..."
	@sleep 5
	@kubectl wait --for=condition=ready pod/$(POD_0) -n $(NAMESPACE) --timeout=300s

restart-ss:
	@echo "🔄 Redémarrage du StatefulSet..."
	@kubectl delete statefulset $(STATEFULSET) -n $(NAMESPACE)
	@sleep 2
	@kubectl apply -f 3-statefulset-postgres.yaml

verify-persistence:
	@echo "✅ Vérification de la persistance des données..."
	@bash scripts/test-persistence.sh

dns-test:
	@echo "🔍 Test de résolution DNS (headless service)..."
	@kubectl run -it --rm --image=busybox --restart=Never -n $(NAMESPACE) -- \
		nslookup postgres-0.postgres.$(NAMESPACE).svc.cluster.local

storage-info:
	@echo "💾 Informations sur le stockage:"
	@echo ""
	@echo "PersistentVolumes:"
	@kubectl get pv -o wide
	@echo ""
	@echo "PersistentVolumeClaims:"
	@kubectl get pvc -n $(NAMESPACE) -o wide

resources:
	@echo "📊 Utilisation des ressources:"
	@kubectl top nodes 2>/dev/null || echo "   (Metrics server pas installé)"
	@kubectl top pods -n $(NAMESPACE) 2>/dev/null || echo "   (Metrics server pas installé)"

# ============================================================================
# Alias pratiques
# ============================================================================

ss: status
st: status
p: pods
pw: pods-watch
l: logs
d: describe
c: check-data
i: insert-data
t: test-persistence
m: monitor

.DEFAULT_GOAL := help
