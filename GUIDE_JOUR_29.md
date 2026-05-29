# 🚀 Guide Complet - Jour 29 (29 mai 2026)

## 📌 GitHub Actions - Pipeline CI/CD Complet

Bienvenue dans le projet du jour ! Ce guide vous aide à naviguer et utiliser le projet.

---

## ⚡ TL;DR (30 secondes)

```bash
# Cloner et tester
cd projects/2026-05-29_github-actions-cicd/
npm install
npm test          # 15 tests, 100% passing ✅
npm run lint      # 0 errors ✅
```

**Fichiers importants :**
- `README.md` → Guide complet (45 min)
- `QUICKSTART.md` → Démarrage rapide (5 min)
- `.github/workflows/ci.yml` → Pipeline principal (183 lignes)

---

## 📂 Structure & Navigation

### 1️⃣ **Par où commencer ?**

```
┌─────────────────────────────────────────┐
│  5 minutes : QUICKSTART.md              │  ← COMMENCEZ ICI
│                                         │
│  45 minutes : README.md (full guide)    │  ← Puis ici
│                                         │
│  30 minutes : Explore workflows YAML    │  ← Comprenez le code
│                                         │
│  30 minutes : BEST-PRACTICES.md         │  ← Apprenez patterns
│                                         │
│  1-2 heures : Exercices pratiques       │  ← Hands-on
└─────────────────────────────────────────┘
```

### 2️⃣ **Documents clés**

| Document | Durée | Niveau | Description |
|----------|-------|--------|-------------|
| **[QUICKSTART.md](projects/2026-05-29_github-actions-cicd/QUICKSTART.md)** | 5 min | Débutant | ✅ Installation + 5 min de code |
| **[README.md](projects/2026-05-29_github-actions-cicd/README.md)** | 45 min | Débutant-Int | ✅ Concepts + étapes + exercices |
| **[BEST-PRACTICES.md](projects/2026-05-29_github-actions-cicd/BEST-PRACTICES.md)** | 30 min | Intermédiaire | ✅ Patterns production |

### 3️⃣ **Workflows GitHub Actions**

| Workflow | Trigger | Rôle | Documentation |
|----------|---------|------|---------------|
| **ci.yml** | push + PR | Lint, test, build | Ligne 1-183 |
| **deploy.yml** | push main | Deploy → staging | Ligne 1-44 |
| **scheduled-checks.yml** | cron | Maintenance hebdo | Ligne 1-77 |

### 4️⃣ **Code Source**

```
src/
├── calculator.js        → Module testé (6 fonctions)
└── index.js            → App HTTP simple

tests/
└── calculator.test.js  → 15 tests Jest (100% coverage)
```

---

## 🎯 Plan d'apprentissage personnalisé

### 🟢 **Débutant complet** (2-3h)
1. Lire `QUICKSTART.md` (5 min)
2. Installer et tester localement (10 min)
3. Lire `README.md` sections 1-3 (30 min)
4. Explorer les workflows YAML (30 min)
5. Faire l'exercice 1 du README (30 min)

### 🟡 **Débutant avec expérience** (3-4h)
1. Parcourir `QUICKSTART.md` (5 min)
2. Tester localement (5 min)
3. Lire `README.md` en entier (45 min)
4. Analyser chaque workflow YAML (45 min)
5. Faire 2-3 exercices du README (1 heure)
6. Lire `BEST-PRACTICES.md` (30 min)

### 🟠 **Intermédiaire** (4-6h)
1. Scanner `QUICKSTART.md` (5 min)
2. Tester, ajouter des modifications (30 min)
3. Lire `README.md` + `BEST-PRACTICES.md` (1 heure)
4. Faire les 4 exercices du README (2 heures)
5. Créer un PR et regarder le CI (30 min)
6. Implémenter le déploiement réel (1 heure bonus)

---

## 🔍 Explorer le Code

### Comment lire les workflows YAML ?

**Structure générale d'un workflow :**

```yaml
name: CI Pipeline                    # Nom du workflow
on:                                  # Quand s'exécute ?
  push:
    branches: [main]
jobs:                                # Liste des jobs
  lint:                              # Job 1
    runs-on: ubuntu-latest           # Sur quel runner ?
    steps:
      - uses: actions/checkout@v4    # Utiliser une action
      - run: npm lint                # Exécuter une commande
      
  test:                              # Job 2
    runs-on: ubuntu-latest
    strategy:                        # Configuration avancée
      matrix:
        node-version: [16.x, 18.x]
    steps:
      - run: npm test
```

**Décodage du ci.yml :**
- **Lignes 1-13** : Triggers (push + PR)
- **Lignes 16-40** : Job "lint" (ESLint + Prettier)
- **Lignes 42-80** : Job "test" (Jest avec matrix)
- **Lignes 82-105** : Job "build" (Docker, si main)
- **Lignes 107-140** : Job "security" (npm audit + Trivy)
- **Lignes 142-165** : Job "notify" (Slack)

---

## 🧪 Exécuter & Tester Localement

### Installation

```bash
cd projects/2026-05-29_github-actions-cicd/
npm install
```

### Tests

```bash
# Tous les tests
npm test

# Mode watch (re-run on file change)
npm run test:watch

# Avec coverage
npm test -- --coverage
```

### Linting

```bash
# Vérifier
npm run lint

# Corriger
npm run lint:fix

# Formatting
npm run format
npm run format:check
```

### Docker

```bash
# Builder
docker build -t devops-app:test .

# Exécuter
docker run -p 3000:3000 devops-app:test

# Tester health check
curl http://localhost:3000/health
```

---

## 💡 Concepts Clés Expliqués

### 📌 Workflows
Un fichier YAML dans `.github/workflows/` qui décrit l'automatisation.

### 📌 Jobs
Unités d'exécution dans un workflow. Peuvent s'exécuter en parallèle.

### 📌 Steps
Les actions concrètes dans un job (code à exécuter).

### 📌 Matrix
Permet de tester sur plusieurs versions/configs simultanément.

```yaml
strategy:
  matrix:
    node-version: [16.x, 18.x, 20.x]  # 3 exécutions parallèles
```

### 📌 Artifacts
Fichiers partagés entre jobs.

```yaml
# Job 1 : Upload
- uses: actions/upload-artifact@v3
  with:
    name: docker-image
    path: image.tar

# Job 2 : Download
- uses: actions/download-artifact@v3
  with:
    name: docker-image
```

### 📌 Secrets
Variables chiffrées pour credentials/tokens.

```yaml
env:
  TOKEN: ${{ secrets.MY_SECRET }}
```

### 📌 Conditions
Exécuter une step conditionnellement.

```yaml
if: github.ref == 'refs/heads/main'        # Si main
if: success()                              # Si succès
if: failure()                              # Si échec
if: always()                               # Toujours
```

---

## 🎮 Exercices Pratiques

### Exercice 1 : Ajouter une condition au build
**Objectif** : Deploy aussi sur les tags

Modifiez `ci.yml` ligne ~83 :

```yaml
if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
```

### Exercice 2 : Ajouter un linter supplémentaire
**Objectif** : Ajouter TypeScript checking

Dans `package.json` :
```json
"devDependencies": {
  "typescript": "^5.0.0"
}
```

Dans `ci.yml` job lint :
```yaml
- run: npx tsc --noEmit
```

### Exercice 3 : Matrix OS
**Objectif** : Tester sur Windows + macOS

Modifiez le job `test` :
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node-version: [18.x]
runs-on: ${{ matrix.os }}
```

### Exercice 4 : Slack notification
**Objectif** : Envoyer les échecs sur Slack

Décommentez la step "Slack Notification" dans `ci.yml`  
Ajoutez un secret `SLACK_WEBHOOK` dans GitHub

---

## 🔗 Ressources Utiles

### Documentation Officielle
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

### Technologies Utilisées
- [Jest Documentation](https://jestjs.io/)
- [ESLint Rules](https://eslint.org/docs/latest/rules/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [npm Docs](https://docs.npmjs.com/)

### Articles & Guides
- [GitHub Actions Best Practices](https://github.blog/enterprise-2-20-github-actions-best-practices/)
- [CI/CD Explained](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-continuous-delivery)

---

## ✅ Checklist d'Apprentissage

- [ ] J'ai lu `QUICKSTART.md`
- [ ] J'ai exécuté `npm install && npm test` localement
- [ ] Je comprends la structure d'un workflow YAML
- [ ] Je sais la différence entre jobs parallèles et séquentiels
- [ ] Je peux expliquer ce qu'est un artifact
- [ ] Je connais les 3 types de triggers (push, PR, cron)
- [ ] J'ai exploré au moins 1 des 3 workflows
- [ ] J'ai fait au moins 1 exercice pratique
- [ ] Je sais où ajouter des secrets GitHub
- [ ] Je comprends matrix builds (multi-version)

---

## 🐛 Troubleshooting

### npm test échoue localement

```bash
# Vérifier la version Node
node --version  # Doit être 16+

# Réinstaller les dépendances
rm -rf node_modules package-lock.json
npm install

# Exécuter un test spécifique
npm test -- --testNamePattern="add"
```

### Workflow ne s'exécute pas sur GitHub

- Vérifier le fichier est dans `.github/workflows/`
- Vérifier la syntaxe YAML (pas de tabs, indentation OK)
- Vérifier les triggers (on: push, on: pull_request)
- Aller dans Actions tab pour voir les logs

### Docker build échoue

```bash
# Vérifier l'image
docker build -t test:latest .

# Voir les erreurs
docker build -t test:latest . --progress=plain
```

---

## 📊 Statistiques Rapides

```
Fichiers       : 17
Code           : 973 lignes
Tests          : 15/15 ✅
Coverage       : 100% ✅
Workflows      : 3
Jobs           : 5
Errors         : 0
Warnings       : 0
Durée à faire  : 4-6h
```

---

## 🎓 Après ce projet

### Prochaines étapes naturelles :

1. **Jenkins** → Pipelines on-premise (alternative GitHub Actions)
2. **GitLab CI** → Concurrent plus features-rich
3. **Kubernetes** → Déployer containers à l'échelle
4. **ArgoCD** → GitOps deployments
5. **Terraform** → Infrastructure as Code

### Compétences acquises :

✅ CI/CD fundamentals  
✅ Automation & workflows  
✅ Testing & quality gates  
✅ Security best practices  
✅ Docker containerization  
✅ Infrastructure as code mindset  

---

## 📞 Support

Si vous êtes bloqué :

1. Vérifiez d'abord les docs du projet (README, QUICKSTART)
2. Consultez BEST-PRACTICES.md pour patterns courants
3. Vérifiez la syntaxe YAML ([YAML Validator](https://jsoncrack.com/editor))
4. Lisez les logs de GitHub Actions (Actions tab)
5. Testez localement en premier (npm test, docker build)

---

## 🎉 Résumé

Ce projet vous enseigne **tout ce qu'un DevOps/SRE fera au quotidien** :

- ✅ Automatiser tests & builds
- ✅ Gérer secrets en production  
- ✅ Déployer reproductiblement
- ✅ Monitorer executions
- ✅ Optimiser performance
- ✅ Sécuriser le pipeline

**Durée estimée** : 4-6 heures  
**Niveau** : Débutant → Intermédiaire  
**Format** : Mains sur les claviers ! 💻

---

**Bonne apprentissage et amusez-vous ! 🚀**

Generated: 2026-05-29
