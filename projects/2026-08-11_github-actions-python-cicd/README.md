# GitHub Actions CI/CD Pipeline pour Application Python

## 🎯 Objectif
Créer une pipeline d'intégration continue (CI/CD) complète pour une application Python Flask utilisant GitHub Actions, avec :
- Tests automatisés (pytest)
- Linting et formatage (flake8, black)
- Containerisation Docker
- Déploiement automatisé sur chaque push vers main

## 📋 Pré-requis
- Git et GitHub (repo configuré)
- Docker Desktop (optionnel, pour tester localement)
- Python 3.9+ (local)
- Compte GitHub avec accès en écriture

## 🛠 Technos Utilisées
- **Framework Web** : Flask (Python)
- **Testing** : pytest, coverage
- **Linting** : flake8, black, pylint
- **CI/CD** : GitHub Actions
- **Containerisation** : Docker
- **Python** : 3.9+

## 📁 Structure du Projet
```
├── README.md
├── app.py                          # Application Flask principale
├── requirements.txt                # Dépendances Python
├── Dockerfile                      # Configuration Docker
├── docker-compose.yml              # Stack locale pour développement
├── .github/workflows/
│   ├── ci.yml                      # Pipeline CI (tests + lint)
│   └── build-and-push.yml          # Build Docker et push (optionnel)
├── tests/
│   ├── test_app.py                 # Tests unitaires
│   └── conftest.py                 # Configuration pytest
└── .flake8                         # Configuration flake8
```

## 🚀 Étapes de Réalisation

### 1. Configuration Locale (Étape 1-2h)
```bash
# Cloner et installer les dépendances
git clone <repo>
cd projects/2026-08-11_github-actions-python-cicd
pip install -r requirements.txt
```

### 2. Développer l'Application Flask (Étape 1-2h)
- Créer `app.py` avec des routes simples
- Health check endpoint (`/health`)
- API endpoint simple (`/api/hello`)

### 3. Écrire les Tests (30-45 min)
```bash
# Lancer les tests
pytest -v --cov=app tests/
```

### 4. Configurer les Workflows GitHub Actions (1-1,5h)
- **CI Workflow** : `lint` → `test` → `coverage report`
- **Build Workflow** : Build Docker image (optionnel)

### 5. Tester la Pipeline (30 min)
- Pousser un commit
- Observer les workflows s'exécuter
- Vérifier les résultats dans l'onglet "Actions"

### 6. Optimisations (30 min optionnel)
- Caching des dépendances pip
- Badges de statut dans README
- Notifications Slack/Discord

## 📚 Ce qu'on Apprend

### DevOps & CI/CD
- ✅ Automatiser tests et linting
- ✅ Pipeline multi-étapes avec GitHub Actions
- ✅ Artefacts et caching dans les workflows
- ✅ Conditions et job dependencies

### Python Best Practices
- ✅ Testing avec pytest et coverage
- ✅ Linting avec flake8
- ✅ Code formatting avec black
- ✅ Configuration pytest avec conftest.py

### Docker
- ✅ Créer un Dockerfile multi-stage
- ✅ Optimiser les layers Docker
- ✅ docker-compose pour le dev local

### GitHub
- ✅ Workflows GitHub Actions
- ✅ Secrets pour les credentials
- ✅ Badges et status checks

## 🔄 Pipeline Exécution

```
Push → GitHub Actions Trigger
       ↓
    [Lint Job]
    ├─ Linter (flake8)
    ├─ Formatter check (black)
    └─ Security scan (bandit)
       ↓ (continue si succès)
    [Test Job]
    ├─ Run pytest
    ├─ Generate coverage
    └─ Upload coverage
       ↓ (continue si succès)
    [Build Job] (optionnel)
    ├─ Build Docker image
    └─ Push to registry
```

## 🧪 Commandes Utiles

```bash
# Tests en local
pytest tests/ -v --cov=app

# Linting
flake8 app.py tests/
black --check app.py tests/
pylint app.py

# Docker local
docker build -t python-app .
docker run -p 5000:5000 python-app

# docker-compose
docker-compose up
docker-compose down
```

## 📊 Résultats Attendus

Après chaque push :
- ✅ Workflow "CI" passe en ~30-60 secondes
- ✅ Tests couvrent 80%+ du code
- ✅ Linting: 0 erreurs
- ✅ Badge de statut visible dans README

## 🎓 Pour Aller Plus Loin

- [ ] Ajouter une étape de "deployment" (vers Heroku, AWS, etc.)
- [ ] Configurer les secrets GitHub (Docker Hub token, AWS credentials)
- [ ] Notifications Slack quand un workflow échoue
- [ ] Merge automatique si CI passe
- [ ] Code analysis avec Sonarqube ou Codacy
- [ ] Performance testing avec locust

## 📝 Liens Utiles

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [pytest Documentation](https://docs.pytest.org/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Best practices for GitHub Actions](https://docs.github.com/en/actions/guides)

---
**Durée estimée** : 4-5 heures | **Niveau** : Débutant → Intermédiaire
