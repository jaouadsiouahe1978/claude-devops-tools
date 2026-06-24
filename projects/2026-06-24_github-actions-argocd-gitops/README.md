# GitHub Actions + ArgoCD - GitOps Pipeline

## 🎯 Objectif du Projet

Mettre en place une pipeline GitOps complète combinant:
- **GitHub Actions**: CI/CD automatisé pour builder et pousser des images Docker
- **ArgoCD**: Déploiement déclaratif et synchronisation automatique depuis Git
- **Kubernetes**: Orchestration des conteneurs
- **GitOps**: Infrastructure as Code avec Git comme source de vérité

À la fin, chaque push sur main déclenchera automatiquement:
1. Build et test de l'application
2. Construction et push de l'image Docker
3. Mise à jour des manifests Kubernetes
4. Synchronisation automatique via ArgoCD

## 📋 Pré-requis

- Docker et Docker CLI (ou Docker Desktop)
- kubectl installé
- Git configuré
- Un compte GitHub
- Optionnel: Minikube ou K3s pour un cluster local

## 🛠️ Technos Utilisées

- **GitHub Actions**: Workflows CI/CD natifs à GitHub
- **Docker**: Containerisation de l'application
- **Kubernetes**: Manifests YAML pour le déploiement
- **ArgoCD**: GitOps operator pour K8s
- **Bash/Python**: Scripts d'automatisation

## 📂 Structure du Projet

```
.
├── .github/
│   └── workflows/
│       ├── build-push.yml        # Build Docker et push
│       └── update-manifests.yml  # Mise à jour des manifests
├── app/
│   ├── server.py                 # Application Flask simple
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/
│   ├── deployment.yaml           # Manifests Kubernetes
│   ├── service.yaml
│   └── argocd-app.yaml           # Définition de l'app ArgoCD
├── argocd/
│   ├── argocd-install.sh          # Script d'installation d'ArgoCD
│   └── initial-setup.sh            # Configuration initiale
└── README.md
```

## 📝 Étapes de Réalisation

### 1️⃣ Préparer l'Application

L'application est une simple API Flask avec un endpoint `/health` pour tester le déploiement.

### 2️⃣ Configurer les Secrets GitHub

```bash
# Ajouter les secrets nécessaires dans GitHub (Settings > Secrets):
- DOCKER_REGISTRY_URL (ex: ghcr.io)
- DOCKER_USERNAME (votre username GitHub)
- DOCKER_PASSWORD (token GitHub avec accès packages)
```

### 3️⃣ Créer la Pipeline GitHub Actions

**build-push.yml**: 
- Teste l'application
- Construit l'image Docker
- Pousse vers le registry

**update-manifests.yml**:
- Met à jour le tag de l'image dans deployment.yaml
- Commit et push automatiquement

### 4️⃣ Installer et Configurer ArgoCD

```bash
# Script fourni pour installer ArgoCD
./argocd/argocd-install.sh

# Configuration des credentials et du repo
./argocd/initial-setup.sh
```

### 5️⃣ Créer l'Application ArgoCD

L'ArgoCD Application (`k8s/argocd-app.yaml`) surveille le repo et synchronise automatiquement les changements.

### 6️⃣ Tester le Pipeline Complet

1. Modifier le code de l'app
2. Pousser sur GitHub
3. Regarder les GitHub Actions s'exécuter
4. Voir ArgoCD synchroniser automatiquement

## 🎓 Concepts Appris

### GitOps
- **Déclaratif**: État souhaité défini dans Git
- **Synchronisation**: Outils qui maintiennent le cluster en sync
- **Audit**: Historique complet via Git
- **Rollback**: Facile via Git revert

### Workflows GitHub Actions
```yaml
# Structure basique
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t app:${{ github.sha }} .
      - name: Push to registry
        run: docker push ${{ env.REGISTRY }}...
```

### ArgoCD
- **Auto-Sync**: Synchronisation automatique avec Git
- **Monitoring**: Web UI pour voir l'état des déploiements
- **Multi-Repo**: Gérer plusieurs repos et clusters
- **RBAC**: Contrôle d'accès granulaire

## 🚀 Lancer le Projet

```bash
# 1. Préparer un cluster Kubernetes (ou Minikube)
minikube start

# 2. Installer ArgoCD
./argocd/argocd-install.sh

# 3. Configurer le repo
./argocd/initial-setup.sh

# 4. Vérifier que tout fonctionne
kubectl get pods -n argocd
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Accéder à https://localhost:8080

# 5. Pousser un changement et observer la synchronisation
echo "v1" > VERSION
git add .
git commit -m "Test GitOps pipeline"
git push origin main
```

## 📊 Monitoring et Troubleshooting

```bash
# Voir les logs d'ArgoCD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Vérifier l'état de synchronisation
argocd app get app-example

# Forcer une synchronisation
argocd app sync app-example

# Voir les logs des Actions
# GitHub > Actions > Workflow run
```

## 💡 Points Clés à Retenir

1. **Git est la source de vérité** - Tous les changements passent par Git
2. **Automatisation complète** - Du code au cluster en un push
3. **Auditabilité** - Chaque déploiement est traçable dans l'historique Git
4. **Récupération de panne** - Rollback simple via `git revert`
5. **Declarative > Imperative** - Décrire l'état, pas les actions

## 🔗 Ressources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [GitOps Principles](https://gitops.tech/)
- [Kubernetes Manifests](https://kubernetes.io/docs/concepts/configuration/overview/)

## ⚡ Durée Estimée: 4-5 heures
- Préparation et compréhension: 30 min
- Installation ArgoCD: 30 min
- GitHub Actions setup: 1h
- Intégration et tests: 1h30
- Dépannage et fine-tuning: 1h

---

**Status**: ✅ Prêt pour apprentissage pratique
**Niveau**: Intermédiaire-Avancé
**Impact**: Compréhension fondamentale du GitOps moderne
