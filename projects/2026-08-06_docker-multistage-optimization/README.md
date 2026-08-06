# 🐳 Docker Multi-stage & Optimization

## Description

Ce projet explore les **meilleures pratiques Docker** pour réduire la taille des images, améliorer les performances et sécuriser les containers.

Nous allons :
- Créer une **application Node.js multi-stage** optimisée
- Comparer les **tailles d'images** avant/après optimisation
- Implémenter le **scanning de sécurité** avec Trivy
- Utiliser **Docker Compose** pour orchestrer un stack complet
- Mettre en place un **registry local** pour tester le push/pull

## Technos

- **Docker** (multi-stage builds, layer optimization, BuildKit)
- **Docker Compose** (v3.8+)
- **Trivy** (sécurité container)
- **Node.js** + Express (application exemple)
- **Alpine Linux** (images légères)
- **jq** (parsing JSON)

## Pré-requis

```bash
# Docker & Docker Compose
docker --version  # 20.10+
docker-compose --version  # 1.29+

# Optionnel : Trivy pour le scanning sécurité
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```

## Étapes de réalisation

### 1. Structure du projet

```
.
├── README.md
├── docker-compose.yml        # Stack complète
├── .dockerignore             # Optimiser build context
├── app/
│   ├── Dockerfile.bad        # Antipattern (gros, non optimisé)
│   ├── Dockerfile.optimized  # Multi-stage + best practices
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
├── scripts/
│   ├── build.sh              # Builder les images
│   ├── compare-sizes.sh      # Comparer les tailles
│   ├── scan-security.sh      # Trivy scanning
│   └── push-registry.sh      # Push au registry local
└── Makefile
```

### 2. Réaliser le projet

#### Étape 1 : Lancer le registry local

```bash
docker-compose up -d registry
docker-compose logs registry
```

#### Étape 2 : Builder les images (mauvaise et optimisée)

```bash
make build
# Ou manuellement :
docker build -f app/Dockerfile.bad -t app:bad .
docker build -f app/Dockerfile.optimized -t app:optimized .
```

#### Étape 3 : Comparer les tailles

```bash
make compare-sizes
```

Vous verrez une différence **massive** (ex: 500MB → 50MB).

#### Étape 4 : Scanner la sécurité

```bash
make scan
```

Cela affiche les **vulnérabilités CVE** de chaque image.

#### Étape 5 : Lancer le stack complet

```bash
make up
docker-compose logs -f
```

- **App Node.js** sur http://localhost:3000
- **Nginx reverse proxy** sur http://localhost:80
- **Registry** sur http://localhost:5000

#### Étape 6 : Push au registry

```bash
make push-registry
curl http://localhost:5000/v2/_catalog  # Vérifier
```

#### Étape 7 : Nettoyer

```bash
make down
make clean
```

## Ce qu'on apprend

### 🎯 Multi-stage builds
- Séparer les **build dependencies** des **runtime dependencies**
- Réduire la taille finale en **ne copiant que l'artifact compilé**
- Exemple : Node avec `npm ci` dans une étape → copier juste `node_modules` et `dist`

### 📦 Optimisations Docker
- **Layer caching** : ordonner les Dockerfiles du moins au plus changeant
- **.dockerignore** : exclure node_modules, .git, tests
- **Alpine Linux** : images 10x plus petites (35MB vs 350MB)
- **Non-root user** : sécurité (pas d'exécution en root)

### 🔒 Sécurité
- Scanner les images avec **Trivy** pour trouver les CVE
- **Mettre à jour les bases** (Alpine, npm)
- Utiliser des **images officielles** et à jour
- **Minimiser les layers** pour moins d'exposure

### 🚀 Performance
- **BuildKit** : cache intelligent, build parallèle
- **Docker Compose** : orchestration locale multi-container
- **Registry local** : tester le push/pull en dev

## Résultats attendus

```
$ make compare-sizes

=== IMAGE SIZES COMPARISON ===
app:bad        | 480 MB
app:optimized  | 45 MB
nginx:latest   | 28 MB

Reduction: app:bad → app:optimized = 90.6% savings!

=== SECURITY SCAN ===
app:bad | CRITICAL: 12 | HIGH: 28 | MEDIUM: 45
app:optimized | CRITICAL: 0 | HIGH: 2 | MEDIUM: 8
```

## Commandes utiles

```bash
# Builder sans cache
docker build --no-cache -f app/Dockerfile.optimized -t app:optimized .

# Analyser les layers d'une image
docker history app:optimized

# Inspecter les détails d'une image
docker inspect app:optimized | jq '.[]' | head -50

# Nettoyer les images dangling
docker image prune -a

# Exporter une image en tar
docker save app:optimized > app-optimized.tar
ls -lh app-optimized.tar  # Vérifier la taille finale
```

## Aller plus loin

- **Kaniko** : builder Docker sans daemon (CI/CD)
- **Podman** : alternative à Docker (rootless)
- **Skopeo** : copier des images entre registry
- **Artifact Hub** : trouver des images officielles sécurisées
- **OCI spec** : comprendre les standards d'images containers

## Troubleshooting

**Le registry ne démarre pas**
```bash
docker logs $(docker ps -a | grep registry | awk '{print $1}')
```

**Les images ne push pas**
```bash
# Vérifier que le registry est up
curl http://localhost:5000/v2/_catalog

# Tagguer correctement pour le registry local
docker tag app:optimized localhost:5000/app:v1.0
docker push localhost:5000/app:v1.0
```

**Trivy scan très lent**
```bash
# Utiliser le cache Trivy
trivy image --skip-update app:optimized
```

---

**Créé le** : 2026-08-06  
**Durée estimée** : 1 jour  
**Niveau** : Débutant → Intermédiaire  
**Prérequis** : Docker installé, notions de Linux
