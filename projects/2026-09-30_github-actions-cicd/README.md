# GitHub Actions CI/CD Pipeline

Un projet DevOps complet montrant comment mettre en place un pipeline de CI/CD robuste avec GitHub Actions, incluant tests automatisés, linting, sécurité et déploiement.

## Objectifs du Projet

- ✅ Mettre en place un workflow CI/CD complet avec GitHub Actions
- ✅ Automatiser les tests unitaires et d'intégration
- ✅ Configurer le linting et la vérification de code
- ✅ Implémenter les vérifications de sécurité (SAST)
- ✅ Créer un workflow de déploiement automatisé
- ✅ Gérer les secrets de manière sécurisée
- ✅ Utiliser des actions réutilisables (composite actions)

## Technologies Utilisées

- **GitHub Actions** : Plateforme CI/CD native de GitHub
- **Python** : Langage pour les tests et scripts
- **Docker** : Containerisation et déploiement
- **Poetry** : Gestion des dépendances Python
- **pytest** : Framework de test
- **pylint & flake8** : Linting et code quality
- **Trivy** : Scan de sécurité des images Docker
- **SAST** : Static Application Security Testing

## Structure du Projet

```
2026-09-30_github-actions-cicd/
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Pipeline CI (test, lint, coverage)
│       ├── security.yml              # Scan de sécurité
│       ├── docker-build-push.yml     # Build et push Docker
│       └── deploy.yml                # Déploiement automatisé
├── app/
│   ├── __init__.py
│   ├── main.py                       # Application principale
│   └── utils.py                      # Utilitaires
├── tests/
│   ├── __init__.py
│   ├── test_main.py                  # Tests unitaires
│   └── test_utils.py                 # Tests utilitaires
├── scripts/
│   ├── run-tests.sh                  # Script pour lancer les tests
│   └── deploy.sh                     # Script de déploiement
├── Dockerfile                        # Image Docker
├── pyproject.toml                    # Configuration Poetry
├── .pylintrc                         # Configuration pylint
└── .gitignore
```

## Prérequis

- Compte GitHub avec accès au repository
- Docker installé localement
- Python 3.9+
- Git

## Étapes de Réalisation

### Étape 1: Préparation du Projet Local
```bash
# Cloner le repository
git clone https://github.com/jaouadsiouahe1978/claude-devops-tools
cd projects/2026-09-30_github-actions-cicd

# Installer les dépendances
pip install poetry
poetry install
```

### Étape 2: Configuration des Workflows GitHub Actions
- Créer les fichiers YAML dans `.github/workflows/`
- Configurer les triggers (push, pull_request, schedule)
- Définir les jobs et steps
- Utiliser les actions réutilisables (GitHub Marketplace)

### Étape 3: Mise en Place du Pipeline CI
- Tests automatiques avec pytest
- Linting avec pylint et flake8
- Coverage report
- Upload des résultats

### Étape 4: Sécurité et Scans
- Scan SAST avec Trivy
- Vérification des dépendances
- Scan des secrets

### Étape 5: Build et Déploiement
- Build de l'image Docker
- Push sur Docker Hub/GHCR
- Déploiement automatisé
- Notification de statut

### Étape 6: Tests et Validation
- Tester les workflows manuellement
- Vérifier les notifications
- Simuler les echecs et vérifier la gestion d'erreur

## Ce qu'On Apprend

✅ **Structure des Workflows GitHub Actions**
- Syntax YAML des workflows
- Triggers et événements
- Conditions et contextes

✅ **Gestion de la CI/CD**
- Étapes de test et validation
- Parallélisation des jobs
- Caching pour les performances

✅ **Sécurité**
- Gestion des secrets (secrets.GITHUB_TOKEN)
- Permissions des workflows
- Scans de vulnérabilités

✅ **Actions Réutilisables (Composite Actions)**
- Créer des actions personnalisées
- Abstraire la logique complexe
- Partager entre workflows

✅ **Intégration Continue**
- Tests au chaque commit
- Feedback rapide aux développeurs
- Qualité de code automatisée

✅ **Déploiement Continu**
- Automatiser le déploiement
- Stratégies de déploiement
- Rollback en cas d'erreur

## Configuration des Secrets GitHub

Pour utiliser ce projet, vous devez configurer les secrets GitHub :

1. Aller à: Settings → Secrets and variables → Actions
2. Créer les secrets:
   - `DOCKER_USERNAME`: Votre username Docker Hub
   - `DOCKER_PASSWORD`: Votre token Docker Hub
   - `DEPLOY_KEY`: Clé SSH pour le déploiement
   - `SLACK_WEBHOOK`: URL webhook Slack (optionnel)

## Commandes Utiles

```bash
# Tester localement
poetry run pytest tests/ -v --cov

# Linting
poetry run pylint app/ tests/

# Format du code
poetry run black app/ tests/

# Build Docker
docker build -t github-actions-cicd:latest .

# Valider les workflows YAML
docker run --rm -v $(pwd):/repo rhub/actionlint:latest
```

## Résultats Attendus

Après chaque commit/PR:
- ✅ Tests passent (coverage > 80%)
- ✅ Code lint clean (pylint score > 9.0)
- ✅ Pas de vulnérabilités détectées
- ✅ Image Docker buildée avec succès
- ✅ Déploiement automatisé en environnement de staging

## Liens Utiles

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Awesome GitHub Actions](https://github.com/sdras/awesome-actions)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides)

## Temps Estimé

⏱️ **1 journée complète** :
- Matin: Configuration des workflows de base (3-4h)
- Après-midi: Tests de sécurité et déploiement (3-4h)

## Auteur

Créé comme projet d'apprentissage DevOps/SRE

---

**Bon courage pour explorer GitHub Actions ! 🚀**
