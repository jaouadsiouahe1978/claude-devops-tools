# Docker Optimized Node.js App

## 📌 Objectif
Apprendre à optimiser les images Docker avec les **multi-stage builds** pour réduire la taille des images en production. Ce projet montre comment passer d'une image de 500+ MB à moins de 150 MB.

## 🛠️ Technologies utilisées
- **Docker** : Multi-stage builds, image optimization
- **Docker Compose** : Orchestration de services
- **Node.js** : Application web légère (Express)
- **Alpine Linux** : Image de base légère

## 📋 Prérequis
- Docker installé (≥ 20.10)
- Docker Compose installé (≥ 1.29)
- Git
- Aucune connaissance avancée en Docker requise

## 🎯 Étapes de réalisation

### 1. Analyse du projet (15 min)
- Examiner la structure du projet
- Comprendre le Dockerfile multi-stage
- Voir les différences entre `build stage` et `runtime stage`

### 2. Build l'image Docker (10 min)
```bash
# Build l'image multi-stage
docker build -t devops-app:v1 .

# Voir la taille de l'image
docker images | grep devops-app
```

### 3. Run avec Docker Compose (10 min)
```bash
# Démarrer les services
docker-compose up -d

# Vérifier les logs
docker-compose logs -f app

# Tester l'app
curl http://localhost:3000
curl http://localhost:3000/api/status
```

### 4. Analyse des images (15 min)
```bash
# Comparer les tailles
docker image inspect devops-app:v1 | grep -i size

# Voir les couches de l'image
docker history devops-app:v1

# Vérifier l'optimisation (comparer build stage vs runtime)
docker system df
```

### 5. Exercice pratique (20 min)
- **Bonus** : Créer un second Dockerfile sans multi-stage et comparer les tailles
- **Bonus 2** : Ajouter une couche nginx comme reverse-proxy en multi-stage

## 📚 Ce qu'on apprend

✅ **Multi-stage builds Docker** : Séparer build et runtime pour optimiser la taille
✅ **Optimisation d'images** : Réduire la surface d'attaque et les dépendances
✅ **Docker Compose** : Orchestrer plusieurs services facilement
✅ **Alpine Linux** : Utiliser une image de base ultra-légère
✅ **Bonnes pratiques** :
   - Mettre les couches changeantes en fin de Dockerfile
   - Utiliser `.dockerignore` pour exclure les fichiers inutiles
   - Nettoyer les caches apt/npm dans la même couche RUN

## 🚀 Commandes utiles

```bash
# Build et tag
docker build -t devops-app:latest .

# Run en interactive
docker run -it devops-app:latest

# Inspecteur l'image
docker image inspect devops-app:latest

# Supprimer images/containers
docker system prune -a
```

## 📊 Résultats attendus

| Métrique | Sans multi-stage | Avec multi-stage | Gain |
|----------|------------------|------------------|------|
| Taille image | 800+ MB | ~120 MB | 85% ⬇️ |
| Couches | 12+ | 5 | Réduit |
| Temps build | 45s | 60s* | *premier build |

## 🎓 Ressources
- [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Best practices](https://docs.docker.com/develop/dev-best-practices/)
- [Alpine Linux](https://alpinelinux.org/)

## ✨ Niveau de difficulté
**Débutant / Intermédiaire** - 1 journée (env 2h)
