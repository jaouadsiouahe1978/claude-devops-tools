# 🚀 GitHub Actions CI/CD Pipeline

**Niveau** : Débutant à Intermédiaire  
**Durée estimée** : 1 journée  
**Technos** : GitHub Actions, Docker, Python, Testing, Linting, Deployment

## 📝 Description

Ce projet démontre comment mettre en place une **pipeline CI/CD complète avec GitHub Actions**. Au chaque push ou pull request, les workflows automatisent :

- ✅ **Tests unitaires** et couverture de code
- 🔍 **Linting et formatage** du code
- 🐳 **Construction et push** d'images Docker
- 📦 **Versionnage** automatique
- 🚀 **Déploiement** sur environnements (dev, staging, prod)

## 🎯 Objectif

Créer une application Python simple avec une pipeline CI/CD complète qui :
1. Teste le code à chaque commit
2. Build une image Docker
3. Valide la qualité du code (linting, type checking)
4. Publie les artefacts (releases, Docker images)
5. Déploie automatiquement les changements

## 🛠️ Technos utilisées

| Technologie | Usage |
|-------------|-------|
| **GitHub Actions** | Orchestration CI/CD |
| **Python 3.11** | Application exemple |
| **pytest** | Tests unitaires |
| **flake8** | Linting |
| **black** | Formatage du code |
| **Docker** | Containerisation |
| **GitHub Releases** | Versionnage et artifacts |

## 📋 Pré-requis

- Compte GitHub avec accès au repo
- Git installé localement
- Docker installé (pour tester localement)
- Python 3.11+ (optionnel, pour dev local)

## 🚀 Étapes d'implémentation

### 1. **Initialisation de la pipeline CI/CD**

Les workflows GitHub Actions se trouvent dans `.github/workflows/` :

```bash
ls -la .github/workflows/
# - ci.yml         : Tests et linting
# - build.yml      : Construction Docker
# - deploy.yml     : Déploiement automatique
# - release.yml    : Versionnage et releases
```

### 2. **Push du code et déclencher les workflows**

```bash
git add .
git commit -m "Add GitHub Actions CI/CD pipeline"
git push origin main
```

### 3. **Observer les workflows en action**

Sur GitHub : **Actions** → Cliquer sur le dernier workflow

### 4. **Vérifier les artefacts générés**

- **Releases** : Tags et archives publiées automatiquement
- **Docker Images** : Publiées sur registry (configuré dans secrets)
- **Test Reports** : Rapports de couverture
- **Artifacts** : Logs et résultats de build

## 📚 Ce qu'on apprend

### ✅ Concepts clés

1. **Workflows YAML** : Syntaxe et structure des fichiers workflow
2. **Events & Triggers** : Déclencher les workflows (push, PR, schedule)
3. **Jobs & Steps** : Organiser les tâches sequentiellement et en parallèle
4. **Contexts & Secrets** : Utiliser les variables d'environnement et secrets
5. **Artifacts & Caching** : Optimiser les performances des workflows
6. **Matrix Strategy** : Tester sur plusieurs versions Python/OS
7. **Conditional Execution** : Exécuter des steps conditionnellement
8. **Status Checks** : Bloquer les merges si les checks échouent

### 🔧 Patterns DevOps

- **Semantic Versioning** : Numérotation automatique des versions
- **Docker Multi-stage** : Images optimisées et légères
- **Environment Secrets** : Gestion sécurisée des credentials
- **Deployment Gates** : Approbations avant prod
- **Parallel Testing** : Accélérer les tests avec une matrice

## 📂 Structure du projet

```
2026-08-20_github-actions-cicd/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Tests, linting, type-checking
│       ├── build.yml           # Construction Docker
│       ├── deploy.yml          # Déploiement automatique
│       └── release.yml         # Versionnage et releases
├── src/
│   └── app.py                  # Application Python exemple
├── tests/
│   └── test_app.py             # Tests unitaires
├── Dockerfile                  # Image Docker production
├── docker-compose.yml          # Stack locale (dev/test)
├── .dockerignore              # Fichiers ignorés dans l'image
├── requirements.txt            # Dépendances Python
├── setup.py                    # Configuration du package
├── pyproject.toml              # Config moderne Python (black, pytest)
├── .flake8                     # Config linting
├── .gitignore                  # Fichiers Git ignorés
└── README.md                   # Cette doc
```

## 🔐 Configuration des Secrets

Pour activer le déploiement et la publication Docker, configurez ces secrets dans **GitHub** → **Settings** → **Secrets and variables** → **Actions** :

```bash
DOCKER_USERNAME      # DockerHub username (optionnel)
DOCKER_PASSWORD      # DockerHub token (optionnel)
GITHUB_TOKEN         # Auto-générée, mais peut être customisée
DEPLOY_KEY           # Clé privée SSH pour déploiement
SLACK_WEBHOOK        # Pour notifications Slack (optionnel)
```

**Note** : Les workflows de test fonctionnent sans ces secrets.

## 💻 Utilisation locale

### Installer les dépendances
```bash
python -m venv venv
source venv/bin/activate  # ou `venv\Scripts\activate` sur Windows
pip install -r requirements.txt
```

### Lancer les tests
```bash
pytest -v --cov=src
```

### Vérifier le linting
```bash
flake8 src/ tests/
black --check src/ tests/
```

### Formater le code
```bash
black src/ tests/
```

### Construire l'image Docker
```bash
docker build -t app:latest .
docker run -p 8000:8000 app:latest
```

## 📊 Workflow de développement

1. **Créer une branche** : `git checkout -b feature/xyz`
2. **Coder et commiter** : Les workflows s'exécutent automatiquement sur push
3. **Créer une PR** : Les status checks devront passer (tests, linting)
4. **Merge** : Une fois les checks verts, merge la PR
5. **Release** : Les tags `v*.*.*` déclenchent automatiquement la release

### Exemple de workflow PR
```
git push origin feature/xyz
  ↓
GitHub Actions lance CI (tests, linting)
  ↓
Status checks affichés sur la PR
  ↓
Si ✅, PR peut être mergée
  ↓
Merge → Déclenche déploiement sur main
```

## 🧪 Stratégies de test

Le workflow `ci.yml` utilise une **matrix strategy** pour tester sur plusieurs versions :

```yaml
strategy:
  matrix:
    python-version: ['3.9', '3.10', '3.11', '3.12']
    os: [ubuntu-latest, windows-latest]
```

Cela crée 8 jobs en parallèle pour couvrir toutes les combinaisons.

## 📈 Performances & Optimisation

### Caching
Les dépendances Python sont cachées entre les runs :
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

### Artifacts
Les rapports de test et couverture sont sauvegardés :
```yaml
- uses: actions/upload-artifact@v3
  with:
    name: coverage-report
    path: htmlcov/
```

## 🔗 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Best Practices](https://docs.github.com/en/actions/guides)

## ✨ Points clés à retenir

1. **Les workflows sont dans `.github/workflows/`** - Chaque fichier YAML = un workflow
2. **Les events déclenchent les workflows** - `push`, `pull_request`, `schedule`, etc.
3. **Les jobs s'exécutent en parallèle** - Plus rapide que sequentiel
4. **Utilisez les secrets pour les credentials** - Jamais en dur dans le code
5. **Les status checks bloquent les merges** - Qualité garantie
6. **Le caching accélère les workflows** - Dependencies + build cache
7. **Artifacts pour la persistence** - Logs, reports, binaires

## 📞 Support

Pour toute question, consultez la documentation GitHub Actions officielle ou créez une issue dans le repo.
