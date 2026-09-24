# Container Security Scanning avec Trivy

## 📋 Objectif
Configurer une pipeline d'analyse de sécurité des images Docker avec **Trivy**, un scanner de vulnérabilités open-source. Intégrer le scanning dans CI/CD avec GitHub Actions pour déterminer automatiquement les failles de sécurité avant le déploiement.

## 🛠️ Technologies utilisées
- **Docker** : Conteneurisation
- **Trivy** : Scanner de vulnérabilités
- **GitHub Actions** : Pipeline CI/CD automatisée
- **Bash** : Scripts d'automatisation
- **JSON/YAML** : Configuration et rapports

## 📚 Ce qu'on apprend
- Analyser les vulnérabilités des images Docker
- Générer des rapports de sécurité détaillés (JSON, table, SBOM)
- Automatiser le scanning dans GitHub Actions
- Gérer les dépendances vulnérables
- Appliquer les bonnes pratiques de sécurité container
- Configurer les exclusions et les niveaux de sévérité

## 📦 Prérequis
- Docker installé
- Git & GitHub
- Compte GitHub avec les GitHub Actions activées
- Trivy installé localement (optionnel pour testing)

## 🚀 Étapes de réalisation

### 1. Installation de Trivy localement
```bash
# Installation sur Linux
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install trivy

# Ou avec Docker
docker run aquasec/trivy --version
```

### 2. Analyser une image existante
```bash
trivy image nginx:latest
trivy image --severity HIGH,CRITICAL alpine:latest
```

### 3. Générer différents types de rapports
```bash
# Rapport au format JSON
trivy image --format json --output report.json ubuntu:latest

# Rapport SBOM (Software Bill of Materials)
trivy image --format cyclonedx --output sbom.json ubuntu:latest

# Rapport tabulaire avec CSV
trivy image --format table --output report.txt python:3.9
```

### 4. Pipeline GitHub Actions
La pipeline automatise le scanning à chaque push et création de PR.

### 5. Script d'automatisation
`scan-images.sh` permet de scanner plusieurs images et générer des rapports consolidés.

## 📁 Structure du projet
```
projects/2026-09-24_container-security-scanning/
├── README.md                    # Documentation complète
├── .github/workflows/
│   └── trivy-scan.yml          # Pipeline GitHub Actions
├── scripts/
│   ├── scan-images.sh          # Script de scanning multi-image
│   ├── generate-report.sh      # Génération de rapports consolidés
│   └── check-vulnerabilities.sh # Vérification avec seuils
├── config/
│   └── trivy-config.yaml       # Configuration Trivy
├── Dockerfile                   # Image test avec vulnérabilités intentionnelles
├── Dockerfile.secure           # Image sécurisée
└── test-images.txt             # Liste des images à scanner
```

## 🔧 Utilisation

### Scanning local
```bash
bash scripts/scan-images.sh
```

### Intégration CI/CD
La pipeline GitHub Actions s'exécute automatiquement sur chaque push vers main.

### Rapport consolidé
```bash
bash scripts/generate-report.sh
```

### Vérifier les seuils de sévérité
```bash
bash scripts/check-vulnerabilities.sh ubuntu:latest CRITICAL 0
```

## ✅ Checklist d'apprentissage
- [ ] Installer Trivy sur le système local
- [ ] Scanner une image Docker avec les CLI simples
- [ ] Générer des rapports JSON et SBOM
- [ ] Configurer les niveaux de sévérité
- [ ] Créer les scripts d'automatisation
- [ ] Tester la pipeline GitHub Actions
- [ ] Analyser les résultats et les vulnérabilités
- [ ] Utiliser les exclusions pour les faux positifs
- [ ] Implémenter la politique de scanning dans CI/CD

## 🎯 Objectifs avancés
- Scanner les layers des images pour optimiser
- Intégrer avec une registry privée (DockerHub, ECR, Harbor)
- Créer une alerting basée sur les vulnérabilités critiques
- Générer des SBOM pour la conformité
- Automatiser les mises à jour de dépendances

## 📖 Ressources
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [GitHub Actions + Trivy](https://github.com/aquasecurity/trivy-action)
- [SBOM Standards](https://cyclonedx.org/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

## ⏱️ Durée estimée : 4-6 heures
- Mise en place : 30 min
- Tests locaux : 1h
- Scripts d'automatisation : 1.5h
- Pipeline CI/CD : 1h
- Tests et optimisations : 1-1.5h
