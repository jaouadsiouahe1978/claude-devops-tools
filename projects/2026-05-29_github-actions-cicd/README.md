# GitHub Actions - Pipeline CI/CD Complet

## 📋 Description

Projet complet d'automatisation CI/CD avec GitHub Actions. Vous apprendrez à :
- Créer un workflow multi-job
- Tester automatiquement le code
- Builder une image Docker
- Pousser vers un registre
- Déployer automatiquement
- Gérer les secrets et les permissions

## 🎯 Objectifs d'apprentissage

✅ Comprendre la structure des workflows GitHub Actions  
✅ Créer des jobs parallèles et séquentiels  
✅ Intégrer des tests unitaires dans le pipeline  
✅ Builder et pousser des images Docker  
✅ Utiliser les secrets et variables d'environnement  
✅ Configurer les triggers (push, pull_request, schedule)  
✅ Utiliser des actions tierces (actions/setup-node, docker/setup-buildx-action)  

## 📚 Technologies utilisées

- GitHub Actions (CI/CD)
- Node.js (application test)
- Jest (tests)
- Docker (containerization)
- YAML (configuration)

## 🚀 Structure du projet

```
2026-05-29_github-actions-cicd/
├── README.md                          # Ce fichier
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Pipeline CI (test, lint, build)
│       ├── deploy.yml                # Pipeline déploiement (staging)
│       └── scheduled-checks.yml      # Tâches planifiées (security scans)
├── src/
│   ├── index.js                      # Application simple Node.js
│   └── calculator.js                 # Module à tester
├── tests/
│   └── calculator.test.js            # Tests unitaires Jest
├── Dockerfile                        # Image de l'application
├── package.json                      # Dépendances Node.js
└── .dockerignore                     # Fichiers à ignorer en Docker build
```

## 🔧 Pré-requis

1. **Compte GitHub** avec un repo
2. **Node.js 18+** (pour développement local)
3. **Docker** (optionnel, pour tester localement)
4. **Secrets GitHub** configurés :
   - `DOCKER_REGISTRY_TOKEN` (si vous pushez vers Docker Hub)
   - `DEPLOY_TOKEN` (si vous déployez)

## 📖 Étapes de réalisation

### 1️⃣ Comprendre la structure YAML

- Un workflow = un fichier `.yml` dans `.github/workflows/`
- Chaque workflow contient des **jobs** exécutés sur des **runners**
- Les jobs peuvent être parallèles ou séquentiels (`needs:`)
- Chaque job contient des **steps** (instructions)

### 2️⃣ Créer le workflow de test (CI)

Fichier : `.github/workflows/ci.yml`

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm install
      - run: npm test
      - run: npm run lint
```

**Ce qu'on apprend :**
- Comment déclencher un workflow (on: push, pull_request)
- Comment utiliser des actions officielles (checkout, setup-node)
- Comment exécuter des commandes (run:)

### 3️⃣ Builder et pousser une image Docker

Étendre `ci.yml` avec un job Docker :

```yaml
  docker:
    runs-on: ubuntu-latest
    needs: test  # Attend que les tests passent
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: myregistry/myapp:latest
          context: .
```

**Ce qu'on apprend :**
- La dépendance entre jobs (`needs:`)
- Les conditions d'exécution (`if:`)
- Le build multi-plateforme Docker

### 4️⃣ Créer un workflow de déploiement

Fichier : `.github/workflows/deploy.yml`

```yaml
name: Deploy to Staging

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: staging  # Demande une approbation
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          echo "Deploying to staging..."
          # Votre script de déploiement
```

**Ce qu'on apprend :**
- Les environnements et approbations
- Les secrets GitHub (`secrets.NOM_SECRET`)
- Les variables d'environnement

### 5️⃣ Tâches planifiées (Cron)

Fichier : `.github/workflows/scheduled-checks.yml`

```yaml
name: Scheduled Security Checks

on:
  schedule:
    - cron: '0 2 * * *'  # Chaque jour à 2h UTC

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run npm audit
        run: npm audit --audit-level=moderate || true
```

**Ce qu'on apprend :**
- Les workflows planifiés (cron)
- Comment gérer les erreurs (`|| true`)
- Les tâches de maintenance

## 🎮 Exercices pratiques

### Exercice 1 : Ajouter un linter ESLint
- Installer ESLint : `npm install --save-dev eslint`
- Ajouter un step `npm run lint` dans `ci.yml`

### Exercice 2 : Créer un rapport de couverture de tests
- Configurer Jest avec `--coverage`
- Uploader le rapport avec `codecov/codecov-action@v3`

### Exercice 3 : Matrice de tests (multi-version Node)
```yaml
strategy:
  matrix:
    node-version: [16.x, 18.x, 20.x]
```

### Exercice 4 : Notifications Slack
- Ajouter `slackapi/slack-github-action@v1`
- Configurer un webhook Slack

## 📊 Concepts clés à retenir

| Concept | Explication |
|---------|------------|
| **Workflow** | Fichier YAML définissant l'automatisation |
| **Job** | Unité exécution (peut être parallèle) |
| **Step** | Instruction unique dans un job |
| **Action** | Code réutilisable (built-in ou marketplace) |
| **Runner** | Machine exécutant le workflow |
| **Secret** | Variable sensible chiffrée |
| **Event** | Déclencheur du workflow (push, PR, cron) |

## ✅ Checklist de test

- [ ] Cloner le repo et naviguer au dossier du projet
- [ ] Installer les dépendances : `npm install`
- [ ] Exécuter les tests localement : `npm test`
- [ ] Créer une branche de test : `git checkout -b test-ci`
- [ ] Faire un petit changement et commiter
- [ ] Pousser : `git push origin test-ci`
- [ ] Créer une PR et regarder les workflows s'exécuter
- [ ] Vérifier les logs dans l'onglet "Actions"
- [ ] Voir le résultat du build Docker (ou du déploiement)
- [ ] Merger la PR une fois tous les checks verts ✅

## 🔗 Ressources utiles

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Actions Marketplace](https://github.com/marketplace)
- [Syntax YAML Workflows](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Secrets & Variables](https://docs.github.com/en/actions/learn-github-actions/variables)

## 💡 Points clés à retenir

1. **Actions = Infrastructure as Code** : Tout votre CI/CD est versionné
2. **GitHub fournit des runners gratuits** : ubuntu-latest, windows-latest, macos-latest
3. **Les dépendances entre jobs** : Utilisez `needs:` pour le séquençage
4. **Protégez vos secrets** : Ne commitez JAMAIS de credentials
5. **Réutilisez les actions** : La marketplace GitHub a 20k+ actions
6. **Testez localement** : Utilisez `act` pour simuler les workflows en local

## 🎓 Durée estimée

**⏱️ 1 journée** (4-6h selon votre expérience)

- Compréhension des concepts : 30-45 min
- Création des workflows : 1-2h
- Configuration Docker : 45 min
- Tests et débogage : 1-1.5h
- Bonus (notifications, matrix builds) : 30 min

## 📝 Notes pour Jaouad

Ce projet couvre **les bases essentielles du CI/CD moderne**. C'est exactement ce que vous rencontrerez en SRE/DevOps :
- Automatisation des tests et builds
- Gestion des secrets en production
- Déploiements reproductibles
- Monitoring des jobs (logs)
- Scalabilité (matrix builds pour multi-versions)

Prochaines étapes recommandées :
- Jenkins Pipeline (on-premise alternative)
- GitLab CI (concurrent de GitHub Actions)
- ArgoCD (GitOps / Kubernetes deployments)
