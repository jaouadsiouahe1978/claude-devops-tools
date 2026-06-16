# Résumé du Projet - 2026-06-16

## 🎯 Projet du Jour: Docker Multi-Stage Build pour Node.js

### Thème: Docker (Images Optimisées)

### Technologies Utilisées
- **Docker** - Multi-stage build
- **Docker Compose** - Orchestration
- **Node.js 20** - Runtime
- **Express.js** - Framework web
- **Alpine Linux** - Image légère

### Objectif Principal
Apprendre à réduire drastiquement la taille des images Docker (500MB → 60MB) en utilisant les multi-stage builds, une technique essentielle en DevOps/SRE.

### Concepts Clés Abordés
1. **Multi-Stage Builds** - Séparer les phases de build et de runtime
2. **Layer Caching** - Optimiser l'ordre des commandes
3. **Alpine Linux** - Minimiser la taille de base (5MB vs 200MB)
4. **User Non-Root** - Améliorer la sécurité
5. **Healthcheck** - Monitoring intégré
6. **Docker Compose** - Gestion des ressources et logs

### Fichiers Clés
- `Dockerfile` - Multi-stage avec builder et runtime
- `docker-compose.yml` - Orchestration avec resource limits
- `app/server.js` - Application Express simple
- `scripts/compare.sh` - Comparer single-stage vs multi-stage

### Pour Exécuter
```bash
cd projects/2026-06-16_docker-multistage-nodejs
docker-compose up -d
curl http://localhost:3000
curl http://localhost:3000/health
docker-compose logs -f
```

### Résultats Attendus
✅ Image optimisée (~60MB au lieu de 500MB)
✅ App accessible sur http://localhost:3000
✅ Healthcheck fonctionnel
✅ Logs bien formatés
✅ Arrêt gracieux avec SIGTERM

### Extensions Possibles
- TypeScript compilation dans stage 1
- Nginx reverse proxy
- Scans de sécurité (Trivy)
- Tests en CI/CD
- Multi-architecture builds (buildx)

### Apprentissages DevOps/SRE
- Réduire la surface d'attaque (image plus petite = moins de vulnérabilités)
- Optimiser les temps de déploiement (images plus rapides à télécharger)
- Bonnes pratiques de sécurité (utilisateur non-root)
- Monitoring et observabilité (healthcheck)
- Ressource management
