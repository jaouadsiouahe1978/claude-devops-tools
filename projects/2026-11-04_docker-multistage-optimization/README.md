# Docker Multi-Stage Builds & Image Optimization

## 📋 Description

Ce projet vous apprend à optimiser vos images Docker en utilisant les builds multi-étapes. Vous allez:
- Réduire drastiquement la taille des images (de 500MB à 30MB)
- Améliorer la sécurité en limitant les couches et dépendances
- Implémenter des bonnes pratiques Docker (Alpine, cache busting, layers)
- Comparer les approches single-stage vs multi-stage

## 🎯 Objectifs

1. Comprendre les étapes de build multi-stage
2. Réduire la taille des images Docker
3. Sécuriser les images en supprimant les outils de build
4. Optimiser les couches Docker (layer caching)
5. Automatiser la construction et le push d'images

## 🔧 Technologies & Prérequis

- Docker (version 17.05+)
- Docker Compose
- Un compte sur Docker Hub ou registry local
- git
- Bash/Shell

## 📦 Structure du projet

```
.
├── README.md
├── docker-compose.yml           # Orchestration des services
├── Dockerfile.bad              # Mauvaise approche (image lourde)
├── Dockerfile.good             # Optimisation basique
├── Dockerfile.best             # Multi-stage optimisé
├── src/
│   ├── app.py                  # Application Python simple
│   └── requirements.txt          # Dépendances Python
├── nginx/
│   ├── Dockerfile.bad          # Nginx sans optimisation
│   ├── Dockerfile.best         # Nginx multi-stage
│   └── nginx.conf              # Configuration Nginx
└── scripts/
    ├── build-and-compare.sh    # Script de build et comparaison
    └── push-to-registry.sh     # Script de push d'images
```

## 📚 Étapes de réalisation

### Étape 1: Observer la différence (10 min)
```bash
# Build l'image sans optimisation
docker build -t app:bad -f Dockerfile.bad .

# Build l'image optimisée
docker build -t app:best -f Dockerfile.best .

# Comparer les tailles
docker images | grep app
```

### Étape 2: Analyser les couches (10 min)
```bash
# Voir l'historique des couches
docker history app:bad
docker history app:best

# Inspecter l'image
docker inspect app:best
```

### Étape 3: Tester les images (10 min)
```bash
# Lancer l'application
docker run --rm app:best
docker-compose up -d
```

### Étape 4: Mettre en place le CI/CD local (10 min)
```bash
# Utiliser le script d'optimisation
chmod +x scripts/build-and-compare.sh
./scripts/build-and-compare.sh
```

### Étape 5: Pousser vers un registry (10 min)
```bash
# Tag et push (nécessite Docker Hub login)
./scripts/push-to-registry.sh
```

## 🎓 Ce qu'on apprend

### ✅ Concepts DevOps maîtrisés
- **Multi-stage builds**: Séparer les étapes de compilation et runtime
- **Image layering**: Comprendre le cache Docker et optimiser les couches
- **Base images légères**: Alpine Linux vs Debian
- **Security scanning**: Identifier les vulnérabilités dans les couches
- **Image size reduction**: Techniques de compaction d'images
- **Registry best practices**: Tagging, versioning, push

### ✅ Compétences pratiques
- Écrire des Dockerfile optimisés
- Utiliser `--from` pour référencer les étapes
- Optimiser les `RUN` et les `COPY`
- Utiliser `.dockerignore`
- Automatiser les builds avec des scripts
- Comparer les images avec `docker inspect`

## 🚀 Commandes clés

```bash
# Build multi-stage
docker build -t myapp:latest -f Dockerfile.best .

# Voir les étapes d'un build
docker build --progress=plain -t myapp .

# Inspecter les couches
docker inspect myapp:latest

# Voir l'historique complet
docker history myapp:latest

# Calculer la taille réelle
docker run --rm myapp:latest du -sh /

# Scanner pour les vulnérabilités
docker scan myapp:latest

# Créer une image de debug
docker run -it --entrypoint sh myapp:latest
```

## 📊 Résultats attendus

| Métrique | Sans optimisation | Avec optimisation |
|----------|-------------------|-------------------|
| Taille image | ~500 MB | ~80 MB |
| Nombre de couches | 20+ | 5-8 |
| Temps de pull | ~2 min | ~15 sec |
| Temps de build | ~3 min | ~90 sec |

## ⚠️ Pièges à éviter

- ❌ Mélanger build tools et runtime
- ❌ Oublier `.dockerignore`
- ❌ Utiliser `latest` tag en production
- ❌ Inclure les secrets dans l'image
- ❌ Ne pas utiliser de base image légère
- ❌ Mettre tous les RUN dans une seule commande (mauvais caching)

## 🔐 Bonnes pratiques appliquées

✅ Utiliser Alpine Linux comme base (~5MB)
✅ Builds multi-stage pour séparer build/runtime
✅ Non-root user dans le conteneur
✅ Health checks définis
✅ `.dockerignore` pour exclure les fichiers inutiles
✅ Labels pour le versioning
✅ Logs structurés

## 📖 Ressources complémentaires

- [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Alpine Linux](https://alpinelinux.org/)
- [Distroless images](https://github.com/GoogleContainerTools/distroless)

## 💡 Aller plus loin

1. **Scan de sécurité**: Utiliser `docker scan` ou Trivy
2. **Compression**: Essayer des outils comme `UPX` dans le build
3. **Registry local**: Installer un Nexus/Harbor privé
4. **Buildkit**: Utiliser `DOCKER_BUILDKIT=1` pour des builds plus rapides
5. **Caching**: Utiliser BuildKit cache mounts (`RUN --mount=type=cache`)

---

**Créé le**: 2026-11-04
**Niveau**: Intermédiaire
**Durée**: 1 journée
**Impact DevOps**: ⭐⭐⭐⭐ (essentiellement pour tous les déploiements)
