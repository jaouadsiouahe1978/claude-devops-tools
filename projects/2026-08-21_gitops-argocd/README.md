# 🚀 GitOps avec ArgoCD - Continuous Deployment Automation

**Date:** 21 Août 2026  
**Niveau:** Advanced  
**Durée:** 3-4 heures  
**Technologies:** Kubernetes, ArgoCD, Helm, GitHub, Git  

---

## 📋 Objectif du Projet

Mettre en place une pipeline GitOps complète utilisant **ArgoCD** pour automatiser le déploiement d'applications Kubernetes depuis un référentiel Git. Git devient la source unique de vérité (SSoT) pour tous les déploiements.

### Ce que vous apprendrez

✅ **GitOps Concepts**
- Source unique de vérité (Git)
- Infrastructure as Code (IaC) avec Helm
- Continuous deployment automation
- Progressive delivery patterns

✅ **ArgoCD Setup**
- Installation et configuration d'ArgoCD
- Intégration avec un repositoire Git
- Synchronisation automatique d'applications
- Monitoring et notifications

✅ **Application Deployment**
- Déploiement d'applications via ArgoCD
- Gestion des environnements multiples
- Politique de synchronisation
- Rollback et recovery

✅ **Advanced Features**
- Secret management avec ArgoCD
- Progressive Delivery avec Argo Rollouts
- Notifications et webhooks
- Audit trail et compliance

---

## 🎯 Architecture

```
Git Repository (Source of Truth)
        ↓
    GitHub/GitLab
        ↓
    ArgoCD (Watch & Sync)
        ↓
    Kubernetes Cluster
        ↓
    Applications (Microservices)
```

### Flux GitOps Complet

```
Developer Push Code
    ↓
Git Webhook Trigger
    ↓
ArgoCD detects change
    ↓
ArgoCD syncs Kubernetes
    ↓
Monitoring & Alerts
    ↓
Rollback if needed
```

---

## 📋 Pré-requis

- **Kubernetes cluster** (1.20+)
  - `kubectl` configuré et fonctionnel
  - Accès cluster-admin
  - Minimum 2GB RAM disponible
  
- **Git Repository**
  - GitHub account
  - Fork ou accès au repositoire de config
  
- **Outils CLI**
  ```bash
  kubectl version --client
  helm version
  git version
  ```

- **Optional but Recommended**
  - ArgoCD CLI: `curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64`

---

## 🚀 Étapes de Réalisation

### Étape 1: Installation d'ArgoCD (15 minutes)

```bash
# 1. Créer le namespace ArgoCD
kubectl create namespace argocd

# 2. Installer ArgoCD depuis manifestes officiels
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Vérifier l'installation
kubectl wait -n argocd --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s
kubectl get pods -n argocd
```

### Étape 2: Configuration d'ArgoCD (20 minutes)

```bash
# 1. Exposer ArgoCD en local (dev)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# 2. Récupérer le mot de passe initial
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 3. Accéder à ArgoCD
# URL: https://localhost:8080
# Username: admin
# Password: [from step 2]

# 4. Changer le mot de passe
argocd account update-password
```

### Étape 3: Configurer Git Repository (15 minutes)

```bash
# 1. Ajouter votre repositoire Git à ArgoCD
argocd repo add https://github.com/YOUR_USER/argocd-config \
  --username YOUR_GITHUB_USER \
  --password YOUR_GITHUB_TOKEN

# 2. Vérifier la connexion
argocd repo list
```

### Étape 4: Créer Applications ArgoCD (20 minutes)

```bash
# 1. Créer une Application Guestbook (exemple)
kubectl apply -f applications/guestbook-app.yaml

# 2. Vérifier l'application
argocd app list
argocd app get guestbook
argocd app info guestbook

# 3. Synchroniser l'application
argocd app sync guestbook
```

### Étape 5: Configurer Synchronisation Automatique (15 minutes)

```bash
# 1. Modifier la policy de sync
kubectl patch app guestbook -n argocd \
  -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}' \
  --type merge

# 2. Vérifier
kubectl get application -n argocd
```

### Étape 6: Implémenter Progressive Delivery (20 minutes)

```bash
# 1. Installer Argo Rollouts
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# 2. Créer un Rollout
kubectl apply -f applications/progressive-rollout.yaml

# 3. Tester le déploiement progressif
kubectl set image deployment/rollout-app app=app:v2 -n default
```

### Étape 7: Notifications et Monitoring (15 minutes)

```bash
# 1. Configurer les notifications
kubectl apply -f argocd/notifications-config.yaml

# 2. Ajouter Slack webhook
kubectl patch secret argocd-notifications-secret -n argocd \
  -p '{"data":{"slack-token":"<base64-encoded-token>"}}'

# 3. Tester une notification
argocd app sync guestbook
```

---

## 📁 Structure du Projet

```
projects/2026-08-21_gitops-argocd/
├── README.md                           # Ce fichier
├── argocd/
│   ├── argocd-install.yaml            # Installation complète
│   ├── argocd-config.yaml             # Configuration ArgoCD
│   ├── rbac.yaml                       # RBAC policies
│   ├── notifications-config.yaml       # Notifications Slack/Discord
│   └── ingress.yaml                    # Ingress for ArgoCD UI
├── applications/
│   ├── guestbook-app.yaml             # Application exemple (Helm)
│   ├── nginx-app.yaml                 # Application Nginx
│   ├── progressive-rollout.yaml       # Argo Rollouts example
│   ├── app-of-apps.yaml               # App of Apps pattern
│   └── kustomize-app.yaml             # Kustomize integration
├── helm-charts/
│   ├── guestbook-chart/               # Guestbook Helm Chart
│   ├── nginx-chart/                   # Nginx Helm Chart
│   └── values-dev.yaml                # Dev environment values
├── scripts/
│   ├── install-argocd.sh             # Installation script
│   ├── setup-repo.sh                  # Repository setup
│   ├── create-app.sh                  # Create app script
│   └── test-gitops.sh                 # Test GitOps flow
└── docs/
    ├── GITOPS_CONCEPTS.md             # GitOps theory
    ├── TROUBLESHOOTING.md             # Troubleshooting guide
    └── ADVANCED_PATTERNS.md           # Advanced patterns

Total: 20+ fichiers de configuration
Code Lines: 500+ lignes
```

---

## 🔑 Concepts Clés

### 1. Source Unique de Vérité (SSoT)

```yaml
# Git Repository = Source de Vérité
/config
├── dev/
│   ├── nginx-deployment.yaml
│   ├── nginx-service.yaml
│   └── kustomization.yaml
├── staging/
│   └── ... (same with staging configs)
└── production/
    └── ... (same with prod configs)

# ArgoCD synchronise automatiquement
# Kubernetes ← Git ← Developer Push
```

### 2. Déclaratif vs Impératif

```bash
# ❌ Impératif (ancien)
kubectl set image deployment/nginx nginx=nginx:1.21

# ✅ Déclaratif (GitOps)
# Modifier deployment.yaml dans Git
# ArgoCD détecte et synchronise
git add deployment.yaml
git commit -m "Update nginx to 1.21"
git push origin main
```

### 3. Synchronisation Automatique

```yaml
# ArgoCD auto-sync policy
syncPolicy:
  automated:
    prune: true        # Supprimer les ressources supprimées
    selfHeal: true     # Réconcilier les dérives
  syncOptions:
    - CreateNamespace=true
```

### 4. Progressive Delivery

```yaml
# Argo Rollouts - Stratégies de déploiement
strategy:
  canary:
    steps:
      - setWeight: 20      # 20% of traffic
      - pause: {}
      - setWeight: 50      # 50% of traffic
      - pause: {}
      - setWeight: 100     # 100% of traffic
```

---

## 🎯 Exercices Pratiques

### Exercice 1: Installation de Base

**Objectif:** Installer et configurer ArgoCD

```bash
# 1. Installer ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f argocd/argocd-install.yaml

# 2. Vérifier l'installation
kubectl get pods -n argocd

# 3. Accéder à l'interface
kubectl port-forward svc/argocd-server -n argocd 8080:443
# https://localhost:8080
```

**Validation:** ArgoCD UI accessible, tous les pods running

### Exercice 2: Déployer une Application

**Objectif:** Déployer une application via ArgoCD

```bash
# 1. Créer une Application ArgoCD
kubectl apply -f applications/guestbook-app.yaml

# 2. Synchroniser
argocd app sync guestbook

# 3. Vérifier l'état
argocd app get guestbook

# 4. Accéder à l'application
kubectl port-forward svc/guestbook-ui 3000:80
```

**Validation:** Application running et accessible

### Exercice 3: GitOps Workflow

**Objectif:** Tester le workflow complet Git → ArgoCD → Kubernetes

```bash
# 1. Clone le repositoire de config
git clone https://github.com/YOUR_USER/argocd-config
cd argocd-config

# 2. Modifier une configuration
sed -i 's/replicas: 1/replicas: 3/' guestbook/deployment.yaml

# 3. Commit et push
git add guestbook/deployment.yaml
git commit -m "Scale guestbook to 3 replicas"
git push origin main

# 4. Vérifier la synchronisation automatique
argocd app get guestbook
kubectl get pods -l app=guestbook
```

**Validation:** ArgoCD a synchronisé le changement automatiquement

### Exercice 4: Progressive Delivery

**Objectif:** Tester les déploiements progressifs

```bash
# 1. Installer Argo Rollouts
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# 2. Créer un Rollout
kubectl apply -f applications/progressive-rollout.yaml

# 3. Mettre à jour l'image (canary)
kubectl argo rollouts set image progressive-rollout app=app:v2

# 4. Observer le rollout progressif
kubectl argo rollouts get progressive-rollout --watch
```

**Validation:** Déploiement progressif avec étapes de pause

---

## 🛠️ Fichiers de Configuration

### ArgoCD Installation

```yaml
# argocd/argocd-install.yaml
# Manifeste complet pour installer ArgoCD
# - ArgoCD Server
# - ArgoCD Repository Server
# - ArgoCD Application Controller
# - ArgoCD RBAC Config Server
# - Réplicas, persistent volumes, etc.
```

### Application Definition

```yaml
# applications/guestbook-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR_USER/argocd-config
    targetRevision: main
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Helm Integration

```yaml
# applications/nginx-app.yaml
spec:
  source:
    repoURL: https://github.com/YOUR_USER/helm-charts
    path: nginx
    helm:
      releaseName: nginx
      values: |
        replicas: 3
        image: nginx:1.21
```

---

## 📊 Ce que vous pouvez faire après

1. **Déployer des applications** via Git push
2. **Gérer plusieurs environnements** (dev, staging, prod)
3. **Implémenter progressive delivery** avec Argo Rollouts
4. **Automatiser les rollbacks** en cas d'erreur
5. **Audit complet** de tous les déploiements
6. **Intégrer CI/CD** (GitHub Actions + ArgoCD)
7. **Notifier l'équipe** de chaque changement
8. **Scaler automatiquement** les applications

---

## 🚨 Troubleshooting

### ArgoCD ne synchronise pas

```bash
# 1. Vérifier le statut
argocd app get guestbook

# 2. Voir les logs du controlleur
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f

# 3. Vérifier l'accès au repository
argocd repo list
```

### Application en state "Unknown"

```bash
# 1. Force refresh
argocd app refresh guestbook

# 2. Vérifier le cluster access
kubectl auth can-i get deployments --as=system:serviceaccount:argocd:argocd-application-controller

# 3. Voir les détails
argocd app get guestbook --refresh
```

### Problèmes de permission

```bash
# 1. Vérifier le RBAC
kubectl get clusterrolebinding -l app.kubernetes.io/part-of=argocd

# 2. Appliquer la config RBAC
kubectl apply -f argocd/rbac.yaml

# 3. Redémarrer le controlleur
kubectl rollout restart deployment/argocd-application-controller -n argocd
```

---

## 📚 Ressources Additionnelles

- **Documentation ArgoCD:** https://argo-cd.readthedocs.io/
- **GitOps Guide:** https://www.gitops.tech/
- **Argo Rollouts:** https://argoproj.github.io/argo-rollouts/
- **CNCF GitOps:** https://opengitops.dev/

---

## ✅ Checklist de Vérification

- [ ] ArgoCD installé et accessible
- [ ] Repository Git connecté
- [ ] Première application déployée via ArgoCD
- [ ] Synchronisation automatique fonctionnelle
- [ ] Application mise à l'échelle via Git change
- [ ] Notifications configurées
- [ ] Rollback testé et fonctionnel
- [ ] Documentation lue et comprise

---

## 🎓 Points d'Apprentissage Clés

| Concept | Description |
|---------|-------------|
| **GitOps** | Git comme source unique de vérité pour l'infrastructure |
| **Déclaratif** | Définir l'état désiré, pas les étapes |
| **Reconciliation** | ArgoCD surveille et synchronise constamment |
| **Automated Sync** | Déploiements automatiques à chaque push Git |
| **Progressive Delivery** | Déploiements progressifs avec Argo Rollouts |
| **Audit Trail** | Chaque changement est tracé via Git |
| **Compliance** | Git history = audit complet |

---

## 📝 Notes Importantes

1. **Production Deployment**
   - Utiliser des secrets managers (Sealed Secrets, External Secrets)
   - Configurer les RBAC policies strictes
   - Implémenter les network policies

2. **Security**
   - Protéger l'accès au repository Git
   - Utiliser des tokens GitHub avec scope limité
   - Activer le audit logging

3. **Scale**
   - ArgoCD peut gérer 1000s d'applications
   - Sharding pour très grandes installations
   - Considérer ApplicationSet pour templates

---

**Date de Création:** 21 Août 2026  
**Niveau:** Advanced  
**Temps d'Exécution:** 3-4 heures  
**Formateur:** Claude DevOps Agent  
**Contact:** jsinfo38@gmail.com

---

*GitOps with ArgoCD - Part of DevOps/SRE Expert Certification*  
*Day 107 - Formation Jaouad - Grenoble 2026*
