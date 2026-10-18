# GitOps avec ArgoCD - Déploiement Automatisé Kubernetes

## 📋 Description du Projet

Ce projet vous enseigne les principes de **GitOps** et comment utiliser **ArgoCD** pour automatiser les déploiements Kubernetes. 
ArgoCD synchronise automatiquement l'état réel du cluster avec la configuration stockée dans un dépôt Git.

## 🎯 Objectifs

- Installer et configurer ArgoCD dans un cluster Kubernetes
- Déployer une application via Git (GitOps workflow)
- Implémenter l'auto-synchronisation et la surveillance
- Gérer plusieurs environnements (dev/prod) avec ArgoCD
- Comprendre les applications déclaratives avec ArgoCD

## 🛠️ Technos Utilisées

- **Kubernetes** : Orchestration des conteneurs
- **ArgoCD** : GitOps tool pour synchronisation automatique
- **Git** : Source de vérité pour les configurations
- **Helm** : Gestion des templates Kubernetes (optionnel)
- **kubectl** : CLI Kubernetes

## 📚 Pré-requis

- Un cluster Kubernetes fonctionnel (Kind, Minikube ou cluster cloud)
- `kubectl` installé et configuré
- Accès à un dépôt Git (GitHub, GitLab, Gitea)
- Docker installé localement

## 🚀 Étapes de Réalisation

### 1. Installation d'ArgoCD
```bash
# Créer le namespace
kubectl create namespace argocd

# Installer ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que les pods soient prêts
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Accéder à l'interface ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# URL: https://localhost:8080

# Récupérer le mot de passe initial
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. Configuration de l'Application (files: `application-example.yaml`)
Créer une Application ArgoCD qui pointe vers votre dépôt Git.

### 3. Déploiement d'une Application Exemple
```bash
# Appliquer l'application ArgoCD
kubectl apply -f application-example.yaml

# Vérifier l'état
kubectl get applications -n argocd
argocd app list

# Synchroniser manuellement
argocd app sync myapp
```

### 4. Mise en Place de l'Auto-Synchronisation
Configurer ArgoCD pour synchroniser automatiquement quand le Git change.

### 5. Gestion Multi-Environnements
Organiser la structure Git pour supports dev/staging/production.

## 📖 Ce qu'On Apprend

✅ Les principes de GitOps et ses avantages  
✅ Installation et configuration d'ArgoCD  
✅ Synchronisation déclarative entre Git et Kubernetes  
✅ Gestion d'applications complexes multiservices  
✅ Monitoring et auto-healing avec ArgoCD  
✅ Best practices de déploiement Kubernetes  
✅ Intégration avec CI/CD pipelines  

## 📁 Structure des Fichiers

```
.
├── README.md                    # Ce fichier
├── kind-config.yaml            # Config pour cluster Kind local
├── argocd-install.sh           # Script installation ArgoCD
├── application-example.yaml    # Exemple d'Application ArgoCD
├── app-helm-values.yaml        # Values pour déploiement Helm
├── sync-policy-auto.yaml       # Configuration auto-sync
└── monitoring-argocd.yaml      # Monitoring des applications ArgoCD
```

## 🔗 Ressources Utiles

- [ArgoCD Official Docs](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [Awesome ArgoCD](https://github.com/akuity/awesome-argocd)

## ⚡ Commandes Essentielles

```bash
# Lister les applications
kubectl get applications -n argocd
argocd app list

# Voir le statut d'une app
argocd app get myapp
argocd app logs myapp

# Synchroniser une app
argocd app sync myapp --prune --force

# Accès à l'UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Modifier la policy de sync
kubectl patch app myapp -p '{"spec":{"syncPolicy":{"automated":{"prune":true}}}}' --type merge
```

## 🎓 Cas d'Usage Pratiques

1. **CD Pipeline** : Git push → ArgoCD détecte → Auto-déploie
2. **Disaster Recovery** : Restaurer l'état depuis Git en cas de problème
3. **Multi-cluster** : Déployer la même app sur plusieurs clusters
4. **Environment Management** : Prod = branche main, Dev = branche dev
5. **Policy as Code** : Vérifier conformité avant déploiement

---

**Durée estimée** : 2-3 heures  
**Niveau** : Intermédiaire  
**Créé** : 2026-10-14
