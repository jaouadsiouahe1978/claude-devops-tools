# GitHub Actions CI/CD Pipeline avec Bash Scripting

## 📋 Description
Un projet complet de CI/CD utilisant **GitHub Actions** pour automatiser les tests, le build et le déploiement d'une application Node.js simple. Apprentissage des workflows GitHub, des scripts Bash et de l'intégration continue.

## 🎯 Objectif
- Créer un pipeline CI/CD entièrement automatisé
- Apprendre la syntaxe YAML des workflows GitHub Actions
- Utiliser des scripts Bash pour les tâches complexes
- Mettre en place des checks de qualité (linting, tests, sécurité)
- Implémenter une stratégie de déploiement simple

## 🛠 Technos utilisées
- **GitHub Actions** : Orchestration du pipeline CI/CD
- **Bash** : Scripts d'automatisation
- **Node.js** : Application de démonstration
- **npm** : Gestion des dépendances
- **ESLint** : Analyse de code statique
- **Jest** : Tests unitaires

## 📋 Pré-requis
- Compte GitHub avec un repo (celui-ci)
- Node.js >= 18.x installé localement
- Notions basiques en YAML
- Pas d'infrastructure complexe requise (actions gratuites)

## 🚀 Étapes de réalisation

### 1. Créer la structure du projet
```bash
projects/2026-08-05_github-actions-cicd/
├── README.md
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── src/
│   └── index.js
├── tests/
│   └── index.test.js
├── scripts/
│   ├── lint.sh
│   ├── test.sh
│   └── build.sh
├── package.json
└── .eslintrc.json
```

### 2. Initialiser le projet Node.js
```bash
npm init -y
npm install --save-dev eslint jest @babel/preset-env
npm install axios
```

### 3. Créer l'application de démonstration
Une application simple qui :
- Expose une fonction HTTP
- Effectue des appels API
- Peut être testée

### 4. Configurer ESLint et Jest
- Fichiers de configuration ESLint et Jest
- Scripts npm pour linter et tester

### 5. Créer le workflow CI
Workflow GitHub Actions qui :
- **Trigger** : sur chaque push et pull request
- **Jobs** :
  - Checkout du code
  - Installation des dépendances
  - Linting avec ESLint
  - Exécution des tests avec Jest
  - Upload des rapports de couverture
  - Commentaire automatique sur les PR

### 6. Créer le workflow de déploiement
Workflow de déploiement qui :
- **Trigger** : push sur main (après merge)
- **Jobs** :
  - Build de l'application
  - Création d'une release GitHub
  - Notification de succès

### 7. Ajouter des scripts Bash réutilisables
Scripts pour :
- Valider le code (lint.sh)
- Exécuter les tests (test.sh)
- Builder l'application (build.sh)
- Vérifier les dépendances (check-deps.sh)

## 📚 Ce qu'on apprend

### ✅ GitHub Actions
- Syntaxe YAML des workflows
- Triggers (push, pull_request, schedule)
- Jobs et steps
- Variables d'environnement et secrets
- Artifacts et cache
- Conditions et contrôle de flux
- Matrix builds pour tester plusieurs versions

### ✅ Bash Scripting
- Structurer des scripts réutilisables
- Gestion des erreurs (set -e, trap)
- Arguments et options
- Boucles et conditions
- Intégration avec npm/npm scripts

### ✅ CI/CD Best Practices
- Séparation des concerns (lint, test, build)
- Fail-fast : arrêter rapidement sur erreur
- Artifacts et logs
- Notifications et rapports
- Versioning et releases

### ✅ Tests et Qualité
- Configuration de Jest pour les tests
- ESLint pour la qualité du code
- Couverture de code
- Rapports automatiques

## 🔄 Workflow typique
1. Dev créé une branche et pousse un commit
2. GitHub Actions déclenche CI automatiquement
3. Code validé : lint ✅ tests ✅
4. Dev crée une PR
5. Workflow ajoute un commentaire avec les résultats
6. PR approuvée et mergée sur main
7. Workflow de déploiement se déclenche automatiquement
8. Nouvelle release créée et taguée

## 💡 Extensions possibles
- Ajouter SonarQube pour l'analyse de sécurité
- Intégrer Docker build
- Déploiement automatique sur une VM/cloud
- Notifications Slack
- Gestion des secrets GitHub
- Automated dependency updates (dependabot)

## 📖 Ressources
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Bash Scripting Best Practices](https://mywiki.wooledge.org/BashGuide)

## 🧪 Tester localement
```bash
# Installer les dépendances
npm install

# Linter le code
npm run lint

# Exécuter les tests
npm run test

# Vérifier les scripts Bash
bash ./scripts/lint.sh
```
