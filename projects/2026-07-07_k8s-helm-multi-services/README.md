# Kubernetes Helm Charts pour Application Multi-Services

## 📋 Description du projet

Créer une architecture Kubernetes complète avec Helm pour déployer une application composée de trois micro-services :
- **Frontend** (Nginx) : serveur web statique
- **API Backend** (Node.js) : API REST 
- **PostgreSQL** : base de données

Ce projet apprend à :
- Créer des Helm Charts structurés et réutilisables
- Utiliser les values pour configurer les déploiements
- Gérer les dépendances entre services
- Déployer une application multi-services complète
- Utiliser les templates Helm (ConfigMaps, Secrets, Services)

---

## 🎯 Pré-requis

- **Kubernetes** installé et fonctionnel (minikube, kind, ou cluster réel)
- **Helm 3** installé (https://helm.sh)
- **kubectl** configuré pour accéder au cluster K8s
- Connaissance basique de Kubernetes et YAML

```bash
# Vérifier les installations
helm version
kubectl version --client
```

---

## 📂 Structure du projet

```
helm-charts/
├── Chart.yaml                 # Définition du chart parent
├── values.yaml               # Valeurs par défaut
├── templates/
│   ├── namespace.yaml        # Namespace Kubernetes
│   ├── configmap.yaml        # Configuration globale
│   └── NOTES.txt             # Instructions post-installation
├── charts/
│   ├── frontend/             # Sous-chart Nginx
│   ├── backend/              # Sous-chart API Node.js
│   └── postgresql/           # Sous-chart PostgreSQL
└── environments/
    ├── dev-values.yaml       # Valeurs dev
    ├── prod-values.yaml      # Valeurs prod
    └── test-values.yaml      # Valeurs test
```

---

## 🚀 Étapes de réalisation

### 1. Créer la structure Helm

```bash
cd helm-charts
helm create frontend
helm create backend
helm create postgresql
```

### 2. Configurer le Chart parent (Chart.yaml)

Définir la version, la description et les dépendances

### 3. Configurer chaque sous-service

- **Frontend** : Nginx avec replicas et service NodePort
- **Backend** : Pod Node.js avec variables d'environnement
- **PostgreSQL** : Base de données avec PersistentVolume

### 4. Gérer la configuration avec values.yaml

- Images Docker par environnement
- Replicas et ressources (CPU/Mémoire)
- Ports et endpoints
- Secrets pour les credentials

### 5. Déployer avec Helm

```bash
# Namespace spécifique
kubectl create namespace myapp

# Déploiement dev
helm install myapp ./helm-charts -f environments/dev-values.yaml -n myapp

# Déploiement prod
helm install myapp ./helm-charts -f environments/prod-values.yaml -n myapp

# Vérifier l'installation
helm status myapp -n myapp
kubectl get pods -n myapp
```

### 6. Tester les services

```bash
# Port-forward vers le frontend
kubectl port-forward -n myapp svc/frontend 8080:80

# Port-forward vers l'API
kubectl port-forward -n myapp svc/backend 3000:3000

# Accéder à http://localhost:8080
```

---

## 📚 Ce qu'on apprend

✅ **Helm Charts** : Créer, structurer et déployer des charts réutilisables  
✅ **Templating** : Utiliser Sprig, conditions, loops dans les templates  
✅ **Multi-environnements** : Gérer différentes configurations (dev/test/prod)  
✅ **Dépendances** : Orchestrer plusieurs services interdépendants  
✅ **Best Practices** : Namespaces, labels, annotations, health checks  
✅ **Secrets & Config** : ConfigMaps et Secrets pour la configuration sensible  

---

## 🔧 Fichiers clés à créer

### helm-charts/Chart.yaml
```yaml
apiVersion: v2
name: myapp-platform
version: 1.0.0
appVersion: "1.0"
description: Application multi-services avec Kubernetes
dependencies:
  - name: frontend
    version: 1.0.0
    repository: "file://../frontend"
  - name: backend
    version: 1.0.0
    repository: "file://../backend"
  - name: postgresql
    version: 1.0.0
    repository: "file://../postgresql"
```

### helm-charts/values.yaml (extrait)
```yaml
namespace: myapp

frontend:
  enabled: true
  replicas: 2
  image: nginx:latest
  service:
    type: NodePort
    port: 80
    targetPort: 80

backend:
  enabled: true
  replicas: 2
  image: node:16-alpine
  port: 3000
  database:
    host: postgresql
    port: 5432

postgresql:
  enabled: true
  image: postgres:14
  port: 5432
```

---

## ✅ Critères de réussite

- [ ] Chart parent et sous-charts créés
- [ ] Déploiement réussi en environnement dev
- [ ] Les 3 services sont running (`kubectl get pods`)
- [ ] Communication entre services fonctionnelle
- [ ] Values.yaml gère correctement les configurations
- [ ] Déploiement prod différent du dev
- [ ] Documentation claire et lisible

---

## 🎓 Apprentissage progressif

**Niveau débutant** : Déployer avec les valeurs par défaut  
**Niveau intermédiaire** : Modifier les values, gérer les replicas et ressources  
**Niveau avancé** : Créer des hooks, gérer les upgrades, ajouter Prometheus

---

## 📖 Ressources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/overview/)
- [Helm Template Guide](https://helm.sh/docs/chart_template_guide/)

---

**Durée estimée** : 6-8 heures  
**Difficulté** : Intermédiaire  
**Technos** : Kubernetes, Helm, Docker, YAML
