# GitHub Actions CI/CD Pipeline Multi-Environnement

## Objectif
Créer un pipeline CI/CD complet avec GitHub Actions qui :
- Teste et linte le code automatiquement
- Construit une image Docker
- Déploie sur 3 environnements (dev, staging, prod)
- Nécessite une approbation manuelle avant le déploiement en production
- Gère les secrets de manière sécurisée

## Technologies utilisées
- **GitHub Actions** : Orchestration CI/CD
- **Node.js** : Application d'exemple
- **Docker** : Containerisation
- **ESLint & Jest** : Linting et tests unitaires
- **GitHub Environments** : Gestion des environnements et approbations

## Structure du projet
```
2026-09-15_github-actions-cd-pipeline/
├── .github/workflows/
│   ├── ci-pipeline.yml           # Pipeline CI/CD principal
│   └── deploy-cleanup.yml        # Cleanup des anciennes images
├── src/
│   ├── app.js                    # Application Node.js simple
│   └── app.test.js               # Tests Jest
├── Dockerfile                    # Containerisation
├── docker-compose.yml            # Orchestration locale
├── package.json                  # Dépendances Node.js
├── .eslintrc.json               # Configuration ESLint
├── docker-entrypoint.sh          # Script d'entrée
├── .dockerignore                 # Fichiers à ignorer
└── README.md                     # Ce fichier
```

## Pré-requis
- Repository GitHub avec GitHub Actions activé
- Docker installé localement (pour test)
- Node.js 18+ installé localement
- Accès aux paramètres des Secrets du repository GitHub

## Configuration des Environnements GitHub

Créer 3 environnements dans GitHub (Settings → Environments) :
1. **dev** : Sans restrictions, déploiements automatiques
2. **staging** : Sans restrictions, déploiements automatiques
3. **prod** : Avec approbation requise (reviewer: vous)

Pour chaque environnement, ajouter les secrets :
```
DEPLOY_HOST = votre-serveur.com
DEPLOY_USER = deploy
DEPLOY_KEY = <clé SSH privée en base64>
```

## Étapes de réalisation

### 1. Initialiser le projet
```bash
mkdir -p projects/2026-09-15_github-actions-cd-pipeline
cd projects/2026-09-15_github-actions-cd-pipeline
npm init -y
```

### 2. Installer les dépendances
```bash
npm install express jest @types/jest eslint --save-dev
```

### 3. Créer l'application Node.js
- `src/app.js` : Express app simple (healthcheck, GET /api/version)
- `src/app.test.js` : Tests Jest (2-3 cas de test)

### 4. Configurer ESLint et Jest
- `.eslintrc.json` : Configuration ESLint (airbnb-base recommandé)
- `package.json` : Scripts test, lint, start

### 5. Créer le Dockerfile
- Image de base: node:18-alpine
- Builder multi-stage pour réduire la taille
- Healthcheck intégré
- Port 3000 exposé

### 6. Créer les workflows GitHub Actions
**ci-pipeline.yml :**
- Trigger : Push sur main et PR
- Jobs : 
  - Lint (ESLint)
  - Test (Jest)
  - Build Docker (push uniquement sur main)
  - Deploy Dev (automatique)
  - Deploy Staging (automatique après dev)
  - Deploy Prod (avec approbation manuelle)

**deploy-cleanup.yml :**
- Supprime les images Docker > 7 jours
- Scheduled: tous les lundis

### 7. Tester localement
```bash
npm run lint
npm run test
docker build -t app:local .
docker-compose up
```

## Ce qu'on apprend

### Concepts GitHub Actions
- Workflows, jobs, steps
- Triggers (push, pull_request, schedule, workflow_dispatch)
- Contexts et variables d'environnement
- Secrets et configuration par environnement
- Dépendances entre jobs (needs)
- Caching pour optimiser les builds
- Matrix builds pour tester plusieurs versions

### Déploiement multi-environnements
- Promotion progressive (dev → staging → prod)
- Approbations manuelles pour production
- Différenciation des configurations par environnement
- Gestion des secrets au niveau de l'environnement

### Bonnes pratiques DevOps
- Automatiser les tests et linting
- Immutabilité des artifacts (tag Docker)
- Traçabilité (build number, commit SHA)
- Cleanup automatique des ressources
- Sécurité des secrets en CI/CD

### Docker & Containerisation
- Dockerfile multi-stage pour optimisation
- Healthchecks
- Image size optimization
- Docker Compose pour l'orchestration locale

## Commandes utiles

```bash
# Installer les dépendances
npm install

# Linting
npm run lint
npm run lint:fix

# Tests
npm run test
npm run test:coverage

# Build local
npm run build
docker build -t app:dev .

# Démarrage local avec docker-compose
docker-compose up
docker-compose down

# Tester la connexion
curl http://localhost:3000/api/health
curl http://localhost:3000/api/version
```

## Variables d'environnement

Pour tester le pipeline localement, créer un `.env` (ou `.env.local` selon votre setup) :
```
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
```

## Pipeline d'exemple

```
✓ Push sur main
  ├─ Lint (ESLint) ✓
  ├─ Test (Jest) ✓
  ├─ Build Docker ✓ (push image avec tag latest + commit SHA)
  ├─ Deploy Dev ✓ (automatique)
  ├─ Deploy Staging ✓ (automatique après dev réussi)
  └─ Deploy Prod ⏳ (attend approbation)
     └─ Approuver dans GitHub UI
        └─ Deploy Prod ✓
```

## Monitoring et Notifications

Le workflow GitHub Actions envoie automatiquement :
- Status badges dans le README
- Notifications email en cas d'échec
- Détails de build dans GitHub UI

## Points d'amélioration

Pour aller plus loin :
1. Ajouter une notification Slack/Discord
2. Générer un rapport de coverage SonarQube
3. Ajouter un scan de sécurité (Trivy pour Docker)
4. Implémenter le rollback automatique
5. Ajouter des métriques Prometheus
6. Intégrer ArgoCD pour GitOps
7. Ajouter des tests d'intégration E2E
8. Implémenter le Blue-Green deployment

## Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Workflows Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

## Durée estimée

⏱️ **1 journée** pour :
- Créer l'app Node.js avec tests
- Configurer les workflows GitHub Actions
- Tester le pipeline en local
- Déployer sur les 3 environnements
- Documenter le processus
