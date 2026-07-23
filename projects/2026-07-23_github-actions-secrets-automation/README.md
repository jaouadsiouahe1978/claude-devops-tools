# GitHub Actions - Secrets Management et Automation

## 📋 Description

Projet complet pour maîtriser la gestion des secrets et l'automation avancée avec GitHub Actions. Nous créons un pipeline CI/CD sécurisé qui :
- Gère les secrets et variables d'environnement de façon sécurisée
- Utilise les GitHub Secrets pour les données sensibles
- Automatise le déploiement avec conditions et approvals
- Intègre des checks de sécurité (SonarQube, Trivy, etc.)
- Crée un workflow d'application complète (build, test, scan, deploy)

## 🎯 Objectif

Comprendre comment :
- Configurer et utiliser les secrets GitHub de manière sécurisée
- Créer des workflows complexes avec des conditions et des jobs dépendants
- Implémenter des checks de sécurité et de qualité automatisés
- Gérer l'accès aux secrets avec des roles et permissions
- Automatiser le déploiement avec approvals

## 🛠 Technologies

- **GitHub Actions** : CI/CD native
- **GitHub Secrets** : Gestion des données sensibles
- **GitHub Environments** : Séparation prod/staging
- **Docker** : Conteneurisation
- **YAML** : Configuration des workflows
- **Bash** : Scripts d'automatisation

## 📦 Prérequis

- Compte GitHub avec accès à un repo
- Connaissances de base : Git, Docker, YAML
- Environment créé dans les paramètres GitHub

## 🚀 Étapes de Réalisation

### Étape 1 : Structure de base
```bash
mkdir -p .github/workflows
mkdir -p .github/workflows/scripts
mkdir -p src
```

### Étape 2 : Configuration des environnements et secrets
- Créer deux environnements : `staging` et `production`
- Configurer les secrets pour chaque environnement
- Mettre en place les règles de protection (approvals requis pour prod)

### Étape 3 : Workflow de build et test
- Déclencher automatiquement à chaque push
- Construire l'image Docker
- Exécuter les tests

### Étape 4 : Workflow de sécurité
- Scanner SAST (code statique)
- Scanner de dépendances
- Trivy pour les images Docker

### Étape 5 : Workflow de déploiement
- Déploiement vers staging (automatique)
- Déploiement vers production (avec approval)
- Notifications après déploiement

## 📚 Ce qu'on Apprend

✅ Gestion sécurisée des secrets avec GitHub
✅ Création de workflows complexes avec conditions
✅ Séparation des environnements (staging/prod)
✅ Checks de sécurité automatisés (SAST, SCA, container scanning)
✅ Approvals et protections de branches
✅ Notifications et alertes automatisées
✅ Best practices de CI/CD

## 🔐 Points de Sécurité

- Les secrets ne s'affichent jamais dans les logs
- Utilisation des environments pour les secrets sensibles
- Approvals requis pour la production
- Audit trail de tous les déploiements
- Scan de vulnérabilités avant déploiement

## 📊 Fichiers du Projet

```
.
├── .github/
│   └── workflows/
│       ├── 01-build-test.yml         # Build et tests
│       ├── 02-security-scan.yml      # Scans de sécurité
│       ├── 03-deploy.yml             # Déploiement
│       └── scripts/
│           ├── build.sh              # Script de build
│           ├── test.sh               # Script de test
│           └── deploy.sh             # Script de déploiement
├── src/
│   ├── app.py                        # Application exemple
│   └── requirements.txt               # Dépendances
├── Dockerfile                        # Image Docker
└── README.md
```

## ✨ Commandes Principales

```bash
# Afficher les workflows
gh workflow list

# Voir les runs
gh run list

# Voir les secrets configurés
gh secret list

# Tester le workflow localement (act)
act push -s GITHUB_TOKEN=$GITHUB_TOKEN
```

## 🎓 Pour Aller Plus Loin

- Intégrer des webhooks personnalisés
- Utiliser des runners self-hosted
- Implémenter le GitOps avec ArgoCD
- Ajouter des notifications Slack/Discord
- Utiliser des OIDC tokens au lieu des secrets
