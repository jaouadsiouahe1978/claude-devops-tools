# 📦 DevOps du jour - 2026-07-07

## Kubernetes Helm Charts pour Application Multi-Services

### 🎯 Description du projet

Un projet **Kubernetes complet** avec Helm Charts pour déployer une application multi-services :
- **Frontend** : Nginx (serveur web statique)
- **Backend** : Node.js/API REST
- **Base de données** : PostgreSQL

### ✨ Ce qu'on apprend

✅ **Helm Charts** : Créer, structurer et déployer des charts réutilisables  
✅ **Templating Helm** : Utiliser Sprig, conditions, loops, includes  
✅ **Multi-environnements** : Gérer dev, test, prod avec values différentes  
✅ **Dépendances** : Orchestrer plusieurs services interdépendants  
✅ **Best Practices** : Namespaces, labels, annotations, health checks  
✅ **Secrets & Config** : ConfigMaps et Secrets pour configuration sensible  

### 📂 Structure du projet

```
2026-07-07_k8s-helm-multi-services/
├── Chart.yaml                      # Chart parent
├── values.yaml                     # Valeurs par défaut
├── charts/                         # Sous-charts
│   ├── frontend/                   # Chart Nginx
│   ├── backend/                    # Chart Node.js
│   └── postgresql/                 # Chart PostgreSQL
├── templates/                      # Templates globaux
│   ├── namespace.yaml
│   ├── secret.yaml
│   ├── configmap.yaml
│   └── NOTES.txt
├── environments/                   # Configs par env
│   ├── dev-values.yaml
│   ├── test-values.yaml
│   └── prod-values.yaml
├── deploy.sh                       # Script de déploiement automatisé
├── examples-Dockerfile.nodejs      # Exemple Dockerfile
├── examples-nginx.conf             # Exemple config Nginx
├── COMMANDS.md                     # Référence des commandes
└── README.md                       # Documentation complète
```

### 🚀 Points clés

- **29 fichiers** créés avec code réel et fonctionnel
- **3 sous-charts** (frontend, backend, postgresql) avec templates complets
- **Script deploy.sh** : installation, upgrade, uninstall par environnement
- **Values par env** : replicas, ressources, ports différents dev/test/prod
- **Secrets managés** : configuration sensible via Kubernetes Secrets
- **Health checks** : liveness et readiness probes configurés
- **Documentation** : 50+ commandes kubectl/helm avec exemples

### 🎓 Niveaux

- **Débutant** : Déployer avec `./deploy.sh -e dev`
- **Intermédiaire** : Modifier values.yaml, gérer les replicas
- **Avancé** : Créer des hooks, gérer les upgrades, ajouter monitoring

### ⏱️ Durée estimée

6-8 heures (déploiement + test + exploration)

### 📊 Technos

Kubernetes • Helm 3 • Docker • YAML • kubectl • Bash scripting

### 📍 Localisation

`projects/2026-07-07_k8s-helm-multi-services/`

---

**Commit** : feat: Add 2026-07-07 Kubernetes Helm Charts Multi-Services project  
**Date** : 2026-07-07  
**Status** : ✅ Prêt à déployer
