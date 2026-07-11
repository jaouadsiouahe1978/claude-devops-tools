# Configuration et déploiement

## 1. Prérequis

### Compte Docker Hub
- Créer un compte sur [Docker Hub](https://hub.docker.com/)
- Créer un access token: https://hub.docker.com/settings/security

### GitHub Secrets
Pour que le workflow push vers Docker Hub, il faut configurer les secrets:

#### Étapes:
1. Aller dans le repo Settings → Secrets and variables → Actions
2. Créer les secrets suivants:

```
DOCKER_USERNAME = votre_username_docker_hub
DOCKER_PASSWORD = votre_access_token_docker_hub
```

## 2. Utilisation locale

### Test local
```bash
# Build l'image
docker build -t test-app:local .

# Lancer le conteneur
docker run -p 3000:3000 test-app:local

# Tester l'app
curl http://localhost:3000
curl http://localhost:3000/health
curl http://localhost:3000/info
curl http://localhost:3000/metrics

# Arrêter
docker stop <container_id>
```

### Build multi-architecture
```bash
# Setup buildx
docker buildx create --name mybuilder
docker buildx use mybuilder

# Build pour ARM64 et AMD64
docker buildx build \
  -t username/test-app:latest \
  --platform linux/amd64,linux/arm64 \
  --push .
```

## 3. Workflows GitHub Actions

### Workflow principal: docker-build-push.yml
- **Déclenché par:** push sur main/develop
- **Actions:**
  1. Checkout du code
  2. Setup Docker Buildx (multi-arch)
  3. Login à Docker Hub
  4. Extraction des métadonnées (tags, labels)
  5. Build et push de l'image
  6. Génération du SBOM (Software Bill of Materials)

### Workflow de test: docker-test.yml
- **Déclenché par:** pull_request, push sur branches autres que main/develop
- **Actions:**
  1. Build local
  2. Lancer le conteneur
  3. Tests des endpoints:
     - GET / → Infos app
     - GET /health → Status health
     - GET /info → Détails app
     - GET /metrics → Métriques serveur
     - GET /nonexistent → Test 404
  4. Vérification des logs
  5. Vérification de la taille de l'image

## 4. Tagging automatique

Les images poussées vers Docker Hub sont taguées avec:
- `main-<commit_sha>` - Branche + SHA du commit
- `latest` - Dernière version stable (main)
- `v<numéro_run>` - Numéro du workflow run
- Tags sémantiques (si utilisé avec git tags)

Exemple:
```
docker.io/username/test-app:latest
docker.io/username/test-app:main-abc123def
docker.io/username/test-app:42
```

## 5. Monitorer les builds

### Via GitHub Actions
1. Aller dans repo → Actions tab
2. Voir les workflows en cours/terminés
3. Cliquer sur un workflow pour voir les logs détaillés

### Utiliser l'image pushée
```bash
# Pull depuis Docker Hub
docker pull username/test-app:latest

# Lancer
docker run -p 3000:3000 username/test-app:latest
```

## 6. Optimisations et cache

Le workflow utilise les GitHub Actions Cache pour:
- Mettre en cache les couches Docker
- Accélérer les builds suivants
- Réduire la bande passante

Cache type: `type=gha,mode=max`

## 7. Troubleshooting

### L'image ne se push pas sur Docker Hub
1. Vérifier les secrets dans Settings → Secrets
2. Vérifier les logs du workflow (Actions tab)
3. Vérifier le token Docker Hub (pas expiré)

### Les tests échouent
1. Vérifier que l'app se lance correctement: `docker run test-app:test`
2. Vérifier les logs du conteneur
3. Vérifier les endpoints en local: `curl http://localhost:3000/health`

### Image trop grosse
- Vérifier le Dockerfile multi-stage
- Utiliser `.dockerignore` pour exclure les fichiers inutiles
- Considérer `docker scan` pour analyser l'image

## 8. Prochaines étapes

- [ ] Ajouter le scanning Trivy pour les vulnérabilités
- [ ] Ajouter les notifications Slack
- [ ] Implémenter les tests unitaires
- [ ] Signer les images avec Cosign
- [ ] Archiver les SBOMs
- [ ] Mettre en place les GitOps avec ArgoCD

## Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Metadata Action](https://github.com/docker/metadata-action)
- [Best Practices CI/CD](https://github.com/docker/buildx/blob/master/docs/guides/build-multi-platform-images.md)
