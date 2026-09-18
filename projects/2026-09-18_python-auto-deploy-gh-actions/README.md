# Pipeline CI/CD Automatisé avec GitHub Actions

## 📋 Description
Ce projet montre comment créer un pipeline CI/CD complet avec **GitHub Actions** pour une application Python. À chaque push sur `main`, le code est automatiquement testé, validé avec des outils de qualité, construit dans une image Docker, et deployé (ou prêt à déployer).

**Objectif**: Comprendre les workflows GitHub Actions et automatiser les étapes de validation d'une application.

## 🎯 Ce qu'on apprend
- ✅ Créer et configurer des workflows GitHub Actions (`.yml`)
- ✅ Automatiser les tests unitaires (pytest)
- ✅ Valider le code avec linting (flake8) et formatage (black)
- ✅ Builder et pousser une image Docker vers un registre
- ✅ Concepts de CI/CD : test, build, publish, deploy
- ✅ Secrets et variables d'environnement dans GitHub Actions
- ✅ Notifications et logs de workflow

## 🛠️ Technologies utilisées
- **GitHub Actions** : orchestration des pipelines CI/CD
- **Python 3.11** : langage de l'application
- **pytest** : framework de test
- **flake8** : linter Python
- **black** : formateur de code Python
- **Docker** : containerisation de l'application
- **FastAPI** (optionnel) : framework web léger

## 📂 Structure du projet
```
projects/2026-09-18_python-auto-deploy-gh-actions/
├── .github/
│   └── workflows/
│       └── ci-cd.yml                 # Workflow principal CI/CD
├── app/
│   ├── main.py                       # Application Python principale
│   ├── utils.py                      # Fonctions utilitaires
│   └── test_main.py                  # Tests unitaires
├── Dockerfile                        # Containerisation
├── requirements.txt                  # Dépendances Python
├── .dockerignore                     # Fichiers à exclure du build
├── .gitignore                        # Fichiers à ignorer Git
└── README.md                         # Ce fichier
```

## 🚀 Étapes du pipeline

### 1. **Trigger**
Le workflow s'exécute à chaque :
- Push sur la branche `main`
- Pull Request
- Déclenchement manuel (workflow_dispatch)

### 2. **Checkout**
Clone du code du repository

### 3. **Setup Python**
Installation de Python 3.11

### 4. **Install Dependencies**
Installation des dépendances : `pip install -r requirements.txt`

### 5. **Linting (flake8)**
Vérification de la qualité du code
```bash
flake8 app/ --max-line-length=100 --count --show-source
```

### 6. **Formatting Check (black)**
Vérification que le code est bien formaté
```bash
black --check app/
```

### 7. **Run Tests (pytest)**
Exécution des tests unitaires avec couverture
```bash
pytest app/ -v --cov=app --cov-report=term
```

### 8. **Build Docker Image**
Création de l'image Docker
```bash
docker build -t python-app:latest .
```

### 9. **Push to Registry (optionnel)**
Pousser l'image vers Docker Hub ou GitHub Container Registry
```bash
docker push myregistry/python-app:latest
```

### 10. **Notification**
Notification du statut (succès/échec) via email ou Slack

## 📝 Pré-requis
- Compte GitHub avec un repository
- Docker installé localement (pour tester)
- Python 3.11+
- Accès en lecture/écriture au repository

## 🔑 Secrets à configurer (optionnel)
Si vous voulez pousser les images Docker, ajoutez ces secrets dans GitHub:
- `DOCKER_HUB_USERNAME` : votre username Docker Hub
- `DOCKER_HUB_TOKEN` : votre token Docker Hub
- `REGISTRY_URL` : URL du registre Docker
- `SLACK_WEBHOOK` : webhook Slack pour les notifications

## 🎓 Comment lancer ce projet localement

### 1. Cloner et entrer dans le dossier
```bash
cd projects/2026-09-18_python-auto-deploy-gh-actions
```

### 2. Créer un environnement virtuel
```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou: venv\Scripts\activate  # Windows
```

### 3. Installer les dépendances
```bash
pip install -r requirements.txt
```

### 4. Lancer les tests localement
```bash
pytest app/ -v --cov=app
```

### 5. Valider le linting
```bash
flake8 app/
black --check app/
```

### 6. Formater le code
```bash
black app/
```

### 7. Builder l'image Docker
```bash
docker build -t python-app:latest .
```

### 8. Lancer le conteneur
```bash
docker run -p 8000:8000 python-app:latest
# L'app est accessible sur http://localhost:8000
```

## 🔍 Observer le workflow
1. Push du code → GitHub Actions se déclenche automatiquement
2. Aller sur l'onglet "Actions" du repository
3. Voir les étapes s'exécuter en temps réel
4. Consulter les logs détaillés de chaque étape
5. Recevez une notification si le build échoue

## 💡 Points clés d'apprentissage

| Concept | Apprentissage |
|---------|---------------|
| **GitHub Actions** | Définir des workflows YAML pour l'automatisation |
| **CI/CD** | Automatiser test → build → push → deploy |
| **Qualité de code** | Linting et formatage automatisés |
| **Containerisation** | Packager l'app dans Docker |
| **Secrets** | Gérer les credentials de manière sécurisée |
| **Notifications** | Alerter l'équipe en cas d'erreur |

## 🐛 Troubleshooting

### Le workflow échoue au linting
**Solution**: Formater le code avec `black app/` et relancer

### Les tests échouent
**Vérifier**: Les fichiers de test sont dans `app/test_*.py`
**Déboguer**: Lancer `pytest app/ -v -s` pour voir les logs détaillés

### Erreur de permission Docker
**Si poussant les images**: Vérifier les secrets GitHub (DOCKER_HUB_TOKEN)

### Build Docker échoue
**Vérifier**: Le Dockerfile et requirements.txt sont à jour
**Commande**: `docker build -t test:latest . --verbose`

## 📚 Ressources
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [pytest Documentation](https://docs.pytest.org/)
- [flake8 Guide](https://flake8.pycqa.org/)
- [black Code Formatter](https://github.com/psf/black)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## 🎯 Prochaines étapes (bonus)
1. Ajouter un déploiement vers Heroku/AWS/GCP
2. Intégrer des tests de sécurité (bandit, safety)
3. Publier les résultats de couverture
4. Ajouter des notifications Slack personnalisées
5. Configurer l'auto-merge pour les PRs de dépendances

---
**Durée estimée**: 1-2 heures pour comprendre et configurer  
**Niveau**: Débutant à Intermédiaire  
**Date**: 18 Sep 2026
