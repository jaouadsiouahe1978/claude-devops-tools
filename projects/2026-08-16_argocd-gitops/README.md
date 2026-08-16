# ArgoCD & GitOps - Deployment Pipeline

## 📋 Projet Description

**ArgoCD** est un contrôleur de déploiement GitOps déclaratif pour Kubernetes. Ce projet enseigne les principes du GitOps et comment automatiser les déploiements à partir d'un repository Git.

### Objectif
- Installer et configurer ArgoCD dans un cluster Kubernetes
- Comprendre les principes du GitOps (Git = source de vérité unique)
- Automatiser les déploiements à partir de changements Git
- Gérer plusieurs environnements (dev, staging, prod)
- Monitorer et synchroniser les applications

### Technos Utilisées
- **ArgoCD** - GitOps operator pour Kubernetes
- **Kubernetes** - Container orchestration
- **Git** - Version control (source de vérité)
- **Helm** - Package manager (optionnel)
- **Kustomize** - Template overlays
- **YAML** - Configuration déclarative

---

## 🎯 Prérequis

- Cluster Kubernetes actif (minikube, kind, ou cloud)
- kubectl configuré et fonctionnel
- Git installé
- Helm 3+ (optionnel mais recommandé)
- Accès à un repo Git (GitHub, GitLab, etc.)

### Vérification des prérequis
```bash
kubectl cluster-info
kubectl version --client
git --version
helm version
```

---

## 📚 Ce qu'on apprend

### 1. **GitOps Principles**
   - Git comme source unique de vérité
   - Déclaratif vs Impératif
   - Synchronisation automatique
   - Pull vs Push models

### 2. **ArgoCD Fundamentals**
   - Installation dans un cluster
   - Configuration d'applications
   - Gestion des manifests
   - Auto-sync et manual-sync
   - Health status et sync status

### 3. **Deployment Strategies**
   - Blue-Green deployments
   - Canary releases
   - Progressive rollouts
   - Rollback mechanisms

### 4. **Multi-Environment Management**
   - Dev, Staging, Production environments
   - Kustomize overlays pour différentes envs
   - Secrets management
   - Configuration management

### 5. **Best Practices**
   - Structure de repo Git pour GitOps
   - RBAC et security
   - Monitoring et observabilité
   - Disaster recovery

---

## 🚀 Étapes de Réalisation

### Étape 1: Installation d'ArgoCD
```bash
# Créer namespace argocd
kubectl create namespace argocd

# Installer ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Vérifier l'installation
kubectl get pods -n argocd
```

### Étape 2: Accès à ArgoCD UI
```bash
# Port-forward pour accéder à l'UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Récupérer le mot de passe initial
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Accès : https://localhost:8080
# Login: admin / [password]
```

### Étape 3: Structure du Repo Git
```
my-gitops-repo/
├── environments/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   └── production/
│       ├── kustomization.yaml
│       └── patches/
├── apps/
│   ├── frontend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── backend/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   └── database/
│       ├── statefulset.yaml
│       └── service.yaml
├── charts/ (Helm charts optionnels)
└── docs/
```

### Étape 4: Créer une Application ArgoCD
```bash
# Via CLI
argocd app create my-app \
  --repo https://github.com/user/my-gitops-repo \
  --path apps/frontend \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Ou via l'UI : Applications → New App
```

### Étape 5: Configurer Auto-Sync
```bash
# Dans l'ArgoCD UI ou via CLI
argocd app set my-app --sync-policy automated
argocd app set my-app --auto-prune
argocd app set my-app --self-heal
```

### Étape 6: Test du GitOps Workflow
```bash
# 1. Modifier un manifest dans Git
# 2. Push vers la branche main
# 3. ArgoCD détecte le changement (polling toutes les 3min)
# 4. Application se synchronise automatiquement
# 5. Vérifier le déploiement : kubectl get pods
```

### Étape 7: Notifications & Webhook (Optionnel)
```bash
# Configurer un webhook Git pour sync immédiate
# ArgoCD Settings → Repositories → Add webhook
```

---

## 📁 Fichiers Clés du Projet

### Installation Files
- `install-argocd.sh` - Script automatisé pour installer ArgoCD
- `argocd-values.yaml` - Custom Helm values si utilisation de Helm

### Manifests Kubernetes
- `manifests/deployment.yaml` - Exemple d'application
- `manifests/service.yaml` - Service configuration
- `manifests/kustomization.yaml` - Kustomize configuration

### Exemples d'Applications
- `helm-charts/sample-app/` - Application Helm example
- `scripts/test-app.yaml` - Test application

### Documentation
- `docs/gitops-principles.md` - GitOps concepts
- `docs/argocd-cli.md` - ArgoCD CLI reference
- `docs/troubleshooting.md` - Common issues

---

## 🔍 Points Clés à Comprendre

### Git Workflow en GitOps
```
Developer → Git Push → ArgoCD Webhook → Sync → Kubernetes Cluster → Live App
                           ↓
                    Git Pull Request
                    (monitoring automation)
```

### Sync Statuses
- **Synced** : État de l'app = déclaration Git
- **OutOfSync** : État diffère du manifest Git
- **Unknown** : Impossible de déterminer

### Health Status
- **Healthy** : Tous les objets et ressources en bon état
- **Progressing** : Déploiement en cours
- **Degraded** : Erreurs détectées
- **Unknown** : Impossible à déterminer

---

## 💡 Cas d'Usage Réels

1. **Multi-Tenant SaaS**
   - Chaque client = namespace + ArgoCD application
   - Déploiements au niveau du Git commit

2. **GitOps for Compliance**
   - Tous les changements via Git (auditabilité)
   - Pas de `kubectl apply` manuel

3. **Disaster Recovery**
   - Git repo = backup
   - Redéployer entire cluster depuis Git

4. **Progressive Delivery**
   - Flagger + ArgoCD pour canary deployments
   - Automated rollbacks sur errors

---

## 🛠️ Troubleshooting

### ArgoCD pod stuck in pending
```bash
kubectl describe pod -n argocd argocd-server-xxxx
kubectl logs -n argocd argocd-server-xxxx
```

### Application OutOfSync mais pas de modification
```bash
# Forcer la synchronisation
argocd app sync my-app --force

# Vérifier les diffs
argocd app diff my-app
```

### Webhook ne fonctionne pas
```bash
# Vérifier les logs ArgoCD
kubectl logs -n argocd argocd-server

# Re-créer le webhook dans Git
```

---

## 🎓 Resources Supplémentaires

- [ArgoCD Official Docs](https://argo-cd.readthedocs.io/)
- [GitOps Best Practices](https://argoproj.github.io/cd/operator-manual/best_practices/)
- [Kustomize Documentation](https://kustomize.io/)
- [Kubernetes Deployment Patterns](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

## ✅ Validation du Projet

### Checklist de complétion
- [ ] ArgoCD installé et accessible via UI
- [ ] Repository Git connecté à ArgoCD
- [ ] Application créée et en sync
- [ ] Auto-sync activé et fonctionnel
- [ ] Au moins 2 environnements configurés
- [ ] Webhook Git fonctionnel
- [ ] Déploiement automatique testé
- [ ] Rollback testé

---

## 📊 Durée Estimée

- Installation ArgoCD : 15-20 min
- Configuration repo Git : 20-30 min
- Création & test apps : 30-40 min
- Multi-env setup : 30-40 min
- **Total : ~2-3 heures** (niveau intermédiaire)

---

**Créé le:** 2026-08-16  
**Niveau:** Intermédiaire  
**Temps:** 1 journée  
**Tags:** #gitops #argocd #kubernetes #devops #ci-cd
