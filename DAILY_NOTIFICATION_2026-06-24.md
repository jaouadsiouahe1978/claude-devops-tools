# 📌 Projet DevOps du 24 Juin 2026

## GitHub Actions + ArgoCD - Pipeline GitOps Complète

### 🎯 Objectif

Mettre en place une **pipeline GitOps complète** où Git est la source de vérité unique, avec automatisation du build, du test, du déploiement et de la synchronisation continuelle.

### 🛠️ Technos Utilisées

| Tech | Rôle |
|------|------|
| **GitHub Actions** | CI/CD automation (build, test, push) |
| **ArgoCD** | GitOps deployment operator |
| **Kubernetes** | Container orchestration |
| **Docker** | Application containerization |
| **Flask** | Simple Python API |
| **Kustomize** | Kubernetes configuration management |

### 📂 Structure du Projet

```
projects/2026-06-24_github-actions-argocd-gitops/
├── README.md                          # Documentation principale
├── GITOPS_GUIDE.md                    # Guide complet GitOps
├── EXAMPLES.md                        # 10 exemples pratiques
├── quickstart.sh                      # Script de démarrage rapide
├── .github/workflows/
│   ├── build-push.yml                # Build et push Docker
│   └── update-manifests.yml          # Mise à jour K8s
├── app/
│   ├── server.py                     # Application Flask
│   ├── requirements.txt
│   └── Dockerfile                    # Multi-stage build
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml               # 3 replicas
│   ├── service.yaml                  # ClusterIP + NodePort
│   ├── kustomization.yaml            # Gestion config
│   └── argocd-app.yaml              # ArgoCD Application
└── argocd/
    ├── argocd-install.sh             # Installation
    └── initial-setup.sh              # Configuration
```

### 🚀 Pipeline Architecture

```
Developer Code Push
        ↓
GitHub Actions Triggered
        ├─→ Run Tests
        ├─→ Build Docker Image
        └─→ Push to Registry & Update K8s Manifest
                ↓
ArgoCD Monitors Git Repo
        ↓
Detects Manifest Change
        ↓
Syncs to Kubernetes Cluster
        ├─→ Rolling Update
        ├─→ Health Checks
        └─→ Ready in Production
```

### 💡 Concepts Appris

#### ✅ GitOps Principles
- **Single Source of Truth**: Git est autoritaire
- **Declarative**: État souhaité en YAML
- **Version Control**: Chaque changement tracé
- **Automatic Sync**: ArgoCD maintient la synchronisation
- **Audit Trail**: Historique complet

#### ✅ GitHub Actions
```yaml
# Build et test automatiques
on: [push]
jobs:
  build:
    - Checkout code
    - Run tests
    - Build Docker image
    - Push to registry
    - Update K8s manifest
```

#### ✅ ArgoCD
- **Auto-sync**: Synchronisation continuelle Git → Cluster
- **Declarative**: Manifests K8s en YAML
- **Web UI**: Dashboard pour monitoring
- **RBAC**: Sécurité et contrôle d'accès
- **Multi-repo**: Gérer plusieurs applications

#### ✅ Kubernetes Patterns
- **Deployment**: Gestion des pods avec rolling updates
- **Service**: Exposition interne/externe
- **Namespace**: Isolation des ressources
- **Health Checks**: Liveness et readiness probes

### 📊 Fichiers Clés

| Fichier | Lignes | Purpose |
|---------|--------|---------|
| `.github/workflows/build-push.yml` | ~120 | Build & test workflow |
| `.github/workflows/update-manifests.yml` | ~80 | Manifest update workflow |
| `k8s/deployment.yaml` | ~80 | K8s deployment spec |
| `app/server.py` | ~50 | Flask API |
| `argocd/argocd-install.sh` | ~80 | ArgoCD setup |
| `argocd/initial-setup.sh` | ~70 | Config init |
| **Total** | **~500 lines** | **Production-ready** |

### ✨ Features Incluses

- ✅ **Multi-stage Dockerfile** pour images optimisées
- ✅ **Health endpoints** (/health, /version, /info)
- ✅ **Kubernetes best practices** (probes, resources, affinity)
- ✅ **Automatic image tagging** (sha-based)
- ✅ **Rolling updates** (0 downtime)
- ✅ **Kustomize configuration** pour multi-env
- ✅ **Installation scripts** automatisés
- ✅ **Comprehensive documentation**
- ✅ **10 practical examples**

### 🎓 Ce qu'on Apprend

#### Jour 1: Foundation (4-5h)

**Heure 1-2: Concepts et Setup**
- Qu'est-ce que GitOps?
- Architecture GitHub Actions + ArgoCD
- Installation d'un cluster K8s
- Installation d'ArgoCD

**Heure 2-3: Application et Manifests**
- Docker et containerization
- Kubernetes manifests
- Deployment, service, namespace
- Liveness/readiness probes

**Heure 3-4: GitHub Actions**
- Workflows et triggers
- Multi-step pipelines
- Image building et pushing
- Manifest updates

**Heure 4-5: ArgoCD et Integration**
- Synchronisation automatique
- Web UI monitoring
- Rollback et recovery
- Troubleshooting

### 📈 Progression Pédagogique

```
Débutant  → Intermediate → Advanced
    ↓            ↓            ↓
Concepts   →  Pratique    →  Production
   (30m)       (2h 30m)       (1h)
```

### 🔄 Workflow Utilisateur

```bash
# 1. Préparer l'environnement
minikube start

# 2. Lancer la pipeline complète
bash quickstart.sh  # ~5 minutes, entièrement automatisé

# 3. Tester l'application
curl http://localhost:5000/health

# 4. Modifier le code
vim app/server.py

# 5. Déclencher le déploiement
git add . && git commit -m "Feature" && git push

# 6. Observer la synchronisation
# → GitHub Actions construit
# → ArgoCD synchronise
# → App mise à jour automatiquement
```

### 📚 Ressources Incluses

| Resource | Type | Size |
|----------|------|------|
| README.md | Documentation | 4.5 KB |
| GITOPS_GUIDE.md | Deep dive | 12 KB |
| EXAMPLES.md | Hands-on | 8 KB |
| Source code | Python/YAML | 15 KB |
| Workflows | CI/CD | 6 KB |
| Manifests | K8s | 8 KB |
| Scripts | Bash | 5 KB |

### ⚡ Temps Estimé

| Phase | Duration | Notes |
|-------|----------|-------|
| Reading & Setup | 30 min | Installation, configuration |
| Hands-on (quickstart) | 15 min | Automated setup |
| Testing | 20 min | Health checks, API tests |
| GitHub Actions | 30 min | Understanding workflows |
| ArgoCD Deep Dive | 1h | UI, monitoring, sync |
| Examples & Practice | 1h 30m | 10 examples, variations |
| Troubleshooting | 30 min | Common issues |
| **Total** | **~4-5h** | **1 full day** |

### 🎯 Objectifs d'Apprentissage

Par la fin du projet, vous saurez:

- [ ] Expliquer les principes du GitOps
- [ ] Créer une GitHub Actions workflow
- [ ] Installer et configurer ArgoCD
- [ ] Écrire des Kubernetes manifests
- [ ] Mettre en place un CI/CD pipeline
- [ ] Faire des rolling updates
- [ ] Effectuer des rollbacks
- [ ] Monitorer des déploiements
- [ ] Troubleshooter des problèmes
- [ ] Scaler des applications

### 🔗 Commandes Essentielles

```bash
# Quick start complet
bash quickstart.sh

# ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Application
kubectl port-forward -n gitops-demo svc/gitops-app 5000:80

# Monitoring
kubectl logs -n gitops-demo -l app=gitops-app -f
kubectl get pods -n gitops-demo --watch

# Deployer une modification
git push origin main  # C'est tout! Le reste est automatique
```

### 🏆 Réussite Criteria

✅ Application accessible via HTTP  
✅ ArgoCD UI accessible  
✅ Modification du code → déploiement automatique  
✅ Rolling update sans downtime  
✅ Rollback en 1 commande  
✅ Tous les pods en `Running` et `Ready`  

### 📌 Points Clés à Retenir

1. **Git est autoritaire** - Jamais de kubectl apply direct
2. **Déclaratif c'est mieux** - YAML > scripts
3. **Automatisation c'est économe** - Moins d'erreurs, plus rapide
4. **Auditabilité c'est important** - Git history = audit trail
5. **Récupération c'est facile** - git revert = instant rollback

---

**Créé**: 2026-06-24  
**Temps**: ~4-5 heures  
**Niveau**: Intermédiaire-Avancé  
**Impact**: Compréhension fondamentale du DevOps moderne  
**Status**: ✅ Production-ready avec documentation complète

**Prochaines étapes**: Exécuter `bash quickstart.sh` et suivre les 10 exemples dans EXAMPLES.md
