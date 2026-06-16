# Docker Multi-Stage Build pour Node.js

## 📋 Description
Ce projet apprend à utiliser **Docker Multi-Stage Build** pour créer des images optimisées et légères.
Au lieu de produire une image avec 500MB+, on crée une image finale de ~50-60MB en séparant :
- **Stage 1 (build):** Compile et installe les dépendances
- **Stage 2 (runtime):** Copie uniquement ce qui est nécessaire pour exécuter l'app

## 🎯 Objectif
- Comprendre pourquoi les images Docker multi-stage réduisent drastiquement la taille
- Apprendre la syntaxe et les bonnes pratiques
- Implémenter une app Node.js production-ready avec docker-compose

## 🛠️ Technologies
- **Docker** (multi-stage build)
- **Docker Compose**
- **Node.js** (Express.js)
- **npm** (gestion des dépendances)
- **Alpine Linux** (image de base légère)

## 📦 Structure du projet
```
2026-06-16_docker-multistage-nodejs/
├── README.md                 # Ce fichier
├── Dockerfile               # Multi-stage build pour Node.js
├── docker-compose.yml       # Orchestration locale
├── app/
│   ├── package.json        # Dépendances Node.js
│   ├── package-lock.json   # Lock file
│   └── server.js           # App Express simple
├── .dockerignore           # Fichiers à ignorer dans le build
└── scripts/
    └── compare.sh          # Script pour comparer les tailles d'images
```

## 🚀 Étapes de réalisation

### Étape 1: Créer une app Node.js simple
```bash
cd app/
npm init -y
npm install express
```

### Étape 2: Créer le Dockerfile multi-stage
Le Dockerfile contient 2 stages :
- **Stage 1 (builder):** Image alpine avec Node.js 20, installe les dépendances
- **Stage 2 (runtime):** Image alpine minimaliste, copie uniquement le nécessaire

### Étape 3: Build et test
```bash
# Build l'image
docker build -t myapp:multistage .

# Vérifier la taille
docker images myapp:multistage

# Lancer avec docker-compose
docker-compose up -d

# Tester l'app
curl http://localhost:3000
curl http://localhost:3000/health

# Voir les logs
docker-compose logs -f app
```

### Étape 4: Comparer avec une image single-stage
```bash
./scripts/compare.sh
```

## 📚 Ce qu'on apprend

1. **Multi-Stage Builds** : Réduire la taille des images (500MB → 60MB)
2. **Docker best practices** : .dockerignore, minimal dependencies
3. **Alpine Linux** : Pourquoi c'est la base idéale (5MB vs 200MB pour ubuntu)
4. **Layer caching** : Optimiser l'ordre des commandes pour éviter les rebuilds
5. **Docker Compose** : Lancer l'app avec des variables d'env et des ports mappés
6. **Node.js production** : NODE_ENV=production, npm ci, dépendances dev en stage 1 seulement

## ✅ Résultats attendus

```
# Image multi-stage
$ docker images
REPOSITORY   TAG          SIZE
myapp        multistage   60MB    ✅ Petit et optimisé

# Logs de sortie
$ docker-compose up
app_1  | Server running on port 3000
$ curl http://localhost:3000
{"message":"Hello from multi-stage Docker!","timestamp":"2026-06-16T10:30:00Z"}
```

## 🔧 Nettoyage
```bash
docker-compose down
docker rmi myapp:multistage
```

## 💡 Extensions possibles
- Ajouter un healthcheck dans le Dockerfile
- Implémenter un multi-stage avec TypeScript (compilation en stage 1)
- Tester avec nginx reverse proxy en stage 3
- Utiliser `docker buildx` pour du cross-platform building
- Scans de sécurité avec `docker scan` ou `trivy`
