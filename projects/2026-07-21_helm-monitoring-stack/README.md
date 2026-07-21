# Helm Chart pour un Stack de Monitoring : Prometheus + Grafana

## 📋 Description

Ce projet crée et déploie un stack de monitoring complet sur Kubernetes en utilisant **Helm**, l'outil de gestion de paquets pour K8s. Le chart déploie :
- **Prometheus** : collecteur de métriques et base de données de séries temporelles
- **Grafana** : interface de visualisation et de dashboarding
- **node-exporter** : exporte les métriques du système
- **kube-state-metrics** : métriques sur l'état des ressources Kubernetes

**Problème résolu** : Au lieu d'écrire 100 lignes de manifests YAML, on crée un chart Helm réutilisable et paramétrable qui déploie tout avec une commande.

## 🎯 Objectifs

1. Comprendre la structure d'un Helm chart
2. Apprendre à paramétrer les déploiements avec `values.yaml`
3. Déployer une stack réelle de monitoring
4. Tester le chart avec `helm template` et `helm install`
5. Accéder aux dashboards Grafana

## 🛠️ Technologies utilisées

- **Kubernetes** (kind, minikube, ou cluster réel)
- **Helm 3** (gestionnaire de paquets K8s)
- **Prometheus** (collecte de métriques)
- **Grafana** (visualisation)
- **Docker** (images de base)

## 📦 Structure du Projet

```
helm-monitoring-stack/
├── Chart.yaml                 # Métadonnées du chart
├── values.yaml               # Configuration par défaut
├── values-dev.yaml           # Overrides pour dev
├── values-prod.yaml          # Overrides pour prod
├── templates/
│   ├── namespace.yaml        # Namespace Kubernetes
│   ├── prometheus/
│   │   ├── configmap.yaml    # Config Prometheus
│   │   ├── service.yaml      # Service Prometheus
│   │   └── deployment.yaml   # Deployment Prometheus
│   ├── grafana/
│   │   ├── service.yaml      # Service Grafana
│   │   ├── deployment.yaml   # Deployment Grafana
│   │   └── configmap.yaml    # Dashboards Grafana
│   ├── node-exporter/
│   │   ├── daemonset.yaml    # DaemonSet node-exporter
│   │   └── service.yaml      # Service node-exporter
│   └── kube-state-metrics/
│       ├── deployment.yaml   # Deployment kube-state-metrics
│       └── service.yaml      # Service kube-state-metrics
└── scripts/
    ├── install.sh            # Script de déploiement
    ├── uninstall.sh          # Script de suppression
    └── port-forward.sh       # Script d'accès local
```

## ✅ Pré-requis

- Kubernetes cluster (kind, minikube, EKS, GKE, etc.)
  ```bash
  # Si vous n'avez pas K8s, installer kind
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
  chmod +x ./kind
  ./kind create cluster --name monitoring-lab
  ```
- Helm 3 installé
  ```bash
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  helm version
  ```
- kubectl configuré pour communiquer avec votre cluster

## 🚀 Étapes de Déploiement

### 1. Vérifier la structure du chart
```bash
cd helm-monitoring-stack/
helm lint .                    # Valider le chart
helm template . --debug       # Voir les manifests générés
```

### 2. Déployer le chart
```bash
# Dry-run pour vérifier avant de vraiment déployer
helm install monitoring . --namespace monitoring --create-namespace --dry-run

# Déployer pour de bon
helm install monitoring . --namespace monitoring --create-namespace

# Vérifier le statut
helm status monitoring --namespace monitoring
kubectl get all -n monitoring
```

### 3. Accéder aux dashboards
```bash
# Port-forward pour Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80 &

# Port-forward pour Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090 &

# Ouvrir dans le navigateur
# Grafana : http://localhost:3000 (admin/admin par défaut)
# Prometheus : http://localhost:9090
```

### 4. Configurer Grafana

1. Aller à http://localhost:3000
2. Login avec `admin` / `admin`
3. Ajouter Prometheus comme Data Source :
   - URL : `http://prometheus:9090`
   - Save & test
4. Importer des dashboards pré-configurés depuis les ConfigMaps

### 5. Mettre à jour le chart
```bash
# Modifier values.yaml
helm upgrade monitoring . --namespace monitoring
```

### 6. Nettoyer
```bash
helm uninstall monitoring --namespace monitoring
kubectl delete namespace monitoring
```

## 📚 Ce qu'on apprend

1. **Templating Helm** : utiliser `{{ .Values.xxx }}`, `{{ .Release.Name }}`, boucles et conditions
2. **Gestion des configurations** : ConfigMaps pour Prometheus, Grafana
3. **Déploiement Kubernetes** : Deployments, DaemonSets, Services, ConfigMaps
4. **Monitoring réel** : scraper des métriques, créer des dashboards
5. **Infrastructure-as-Code** : versionner et réutiliser votre stack
6. **Namespaces et RBAC** : isoler les ressources de monitoring

## 🎓 Concepts clés

### Chart Helm
- Structure standard pour packager des apps Kubernetes
- Paramétrisable via `values.yaml`
- Versionnable et réutilisable

### Prometheus
- Scrape des métriques HTTP au format texte
- Stocke les données locales (pas de BD externe)
- Langage PromQL pour requêter les métriques

### Grafana
- Visualise les données de Prometheus
- Crée des tableaux de bord (dashboards)
- Alertes simples

### node-exporter & kube-state-metrics
- Exportent les métriques système et K8s
- Prometheus les scrape toutes les 15 secondes (configurable)

## 🔧 Customisation

### Changer la version des images
```bash
helm install monitoring . \
  --set prometheus.image.tag=v2.50.0 \
  --set grafana.image.tag=10.2.0 \
  -n monitoring
```

### Utiliser des values personnalisées
```bash
helm install monitoring . -f values-prod.yaml -n monitoring
```

### Ajouter du stockage persistant
Modifier `values.yaml` pour ajouter `persistence: enabled: true`

## 🐛 Troubleshooting

```bash
# Voir les logs de Prometheus
kubectl logs -n monitoring deployment/prometheus

# Voir les logs de Grafana
kubectl logs -n monitoring deployment/grafana

# Voir les events K8s
kubectl describe pod -n monitoring prometheus-xxxxx

# Vérifier la résolution DNS
kubectl run -it --rm debug --image=busybox:latest -- nslookup prometheus.monitoring
```

## 🎯 Prochaines étapes

1. Ajouter des exporters supplémentaires (MySQL, PostgreSQL, Redis)
2. Implémenter des alertes Prometheus
3. Ajouter Alertmanager pour router les alertes
4. Créer des dashboards personnalisés pour votre app
5. Implémenter du backup de Prometheus
6. Ajouter Thanos pour le long-terme storage

## 📖 Références

- [Helm Documentation](https://helm.sh/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)

## 📝 Notes d'apprentissage

Ce projet démontre comment industrialiser le déploiement d'une stack complexe via l'Infrastructure-as-Code. C'est exactement ce que font les SRE et DevOps en production.
