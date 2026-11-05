# Docker Security & Registry - Build, Scan, Push

## Objectif
Maîtriser le cycle complet de sécurité des images Docker : construction optimisée, scanning des vulnérabilités, push vers registry, et automatisation avec CI/CD.

## Technos utilisées
- **Docker** : Construction et gestion d'images
- **Docker Registry** : Registry local pour stocker les images
- **Trivy** : Scanner de vulnérabilités pour images Docker
- **GitHub Actions** : Automatisation du pipeline CI/CD
- **docker-compose** : Orchestration locale du registry

## Pré-requis
- Docker et Docker Compose installés
- Git
- Account GitHub pour les Actions
- Accès à ntfy.sh pour notifications (optionnel)

## Étapes de réalisation

### 1. Construire une image sécurisée (30 min)
- Utiliser multi-stage build pour réduire la taille
- Utiliser des images de base minimales (alpine, distroless)
- Éviter l'utilisateur root
- Analyser l'image résultante

```bash
docker build -t my-app:v1 -f Dockerfile .
docker image inspect my-app:v1
```

### 2. Scanner les vulnérabilités (20 min)
- Installer Trivy localement
- Scanner l'image pour CVEs
- Générer un rapport JSON/HTML

```bash
trivy image my-app:v1
trivy image --format json --output report.json my-app:v1
```

### 3. Setup Docker Registry local (20 min)
- Lancer un registry Docker Compose
- Configurer authentification (optionnel)
- Tester push/pull

```bash
docker-compose up -d
docker tag my-app:v1 localhost:5000/my-app:v1
docker push localhost:5000/my-app:v1
```

### 4. Automatiser avec GitHub Actions (30 min)
- Créer un workflow qui :
  - Build l'image
  - Scan avec Trivy
  - Génère rapport
  - Pousse vers registry (si scan OK)
- Ajouter des checks et notifications

### 5. Tests et documentation (20 min)
- Vérifier le pipeline complet
- Documenter les résultats
- Créer script de cleanup

## Ce qu'on apprend
✅ Optimisation des images Docker (multi-stage, alpine, distroless)  
✅ Principes de sécurité : pas de root, scan des CVEs, minimal  
✅ Déploiement d'un registry Docker local  
✅ Scanning automatisé avec Trivy  
✅ CI/CD avec GitHub Actions  
✅ Gestion d'artefacts et reports  
✅ Bonnes pratiques DevOps sécurité  

## Résultats attendus
- Une image Docker optimisée < 100MB
- Un scan Trivy clean (0 vulnérabilités critiques)
- Un workflow GitHub Actions fonctionnel
- Un registry local avec images taggées
- Un rapport de sécurité en JSON/HTML
