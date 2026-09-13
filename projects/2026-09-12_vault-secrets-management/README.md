# Vault Secrets Management & Dynamic Credentials

## Description
Ce projet apprend à déployer et configurer **HashiCorp Vault**, un outil de gestion centralisée de secrets en production.

Vous allez :
- Déployer Vault en mode dev dans Docker
- Créer et manager des secrets statiques
- Configurer les dynamic credentials pour PostgreSQL (génération automatique de credentials)
- Utiliser l'authentification AppRole pour les applications
- Mettre en place un système de rotation de secrets

## Prérequis
- Docker & Docker Compose installés
- curl ou Postman pour tester les APIs
- Connaissance basique de JSON
- Terminal Linux/Mac/WSL

## Technos Utilisées
- **Vault** - Secret manager (version OSS)
- **PostgreSQL** - Base de données pour démontrer les dynamic credentials
- **Docker/Docker Compose** - Pour l'orchestration
- **curl/Bash** - Pour les scripts d'intégration

## Architecture
```
┌─────────────────┐
│   Application   │
│   (API Client)  │
└────────┬────────┘
         │
    Uses API
         │
┌────────▼────────────────────┐
│  Vault Server (Container)   │
│  - Secret Storage           │
│  - Dynamic Credentials      │
│  - Audit Logging            │
└────────┬────────────────────┘
         │
    Manages
         │
┌────────▼────────────────────┐
│  PostgreSQL (Container)     │
│  - Data Backend             │
│  - User Management          │
└─────────────────────────────┘
```

## Étapes de Réalisation

### Étape 1 : Démarrer l'infrastructure
```bash
# Démarrer Vault et PostgreSQL
docker-compose up -d

# Vérifier que Vault est accessible
curl http://localhost:8200/v1/sys/health
```

### Étape 2 : Initialiser Vault
```bash
# Exécuter le script d'initialisation
bash init.sh
```

Ce script va :
- Initialiser Vault
- Créer les clés de déverrouillage
- Déverrouiller Vault
- Créer une politique de test

### Étape 3 : Ajouter des Secrets Statiques
```bash
# Créer un secret
vault kv put secret/database/credentials \
  username="admin" \
  password="super-secret-password"

# Lire le secret
vault kv get secret/database/credentials
```

### Étape 4 : Configurer les Dynamic Credentials pour PostgreSQL
```bash
# Configurer la connexion à la base de données
vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly" \
  connection_url="postgresql://{{username}}:{{password}}@postgres:5432/vault_demo" \
  username="vaultadmin" \
  password="vaultpass123"

# Créer un rôle readonly avec TTL
vault write database/roles/readonly \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';" \
  default_ttl="1h" \
  max_ttl="24h"
```

### Étape 5 : Générer des Credentials Dynamiques
```bash
# Générer des credentials automatiques
vault read database/creds/readonly

# Résultat :
# lease_id     : database/creds/readonly/a1b2c3d4
# lease_duration : 3600
# username     : v_root_readonly_a1b2c3
# password     : g4H9kL2mN5pQ8rS

# Ces credentials expirent automatiquement après 1h
```

### Étape 6 : Configurer AppRole pour l'authentification d'application
```bash
# Activer l'authentification AppRole
vault auth enable approle

# Créer un rôle AppRole
vault write auth/approle/role/my-app \
  token_ttl=1h \
  token_max_ttl=24h \
  policies="default,my-app-policy"

# Obtenir les identifiants
vault read auth/approle/role/my-app/role-id
vault generate auth/approle/role/my-app/secret-id
```

### Étape 7 : Intégrer dans une Application
```bash
# S'authentifier avec AppRole
ROLE_ID="..."
SECRET_ID="..."

TOKEN=$(curl -X POST http://localhost:8200/v1/auth/approle/login \
  -d "{\"role_id\":\"$ROLE_ID\",\"secret_id\":\"$SECRET_ID\"}" \
  | jq -r '.auth.client_token')

# Lire les secrets
curl -H "X-Vault-Token: $TOKEN" \
  http://localhost:8200/v1/kv/data/secret/database/credentials
```

## Ce qu'on Apprend

✅ **Concepts clés** :
- Différence entre secrets statiques et dynamiques
- Lease lifecycle & expiration automatique
- Authentification & autorisation avec les policies
- Audit trail complet

✅ **Skills pratiques** :
- Déployer Vault en production-ready mode
- Intégration PostgreSQL pour dynamic credentials
- Scripting d'authentification AppRole
- Gestion des rotations de secrets

✅ **Use cases réels** :
- Secrets management dans une architecture microservices
- Credentials pour services cloud (AWS, GCP, etc.)
- Compliance & audit (trace complète de qui accède à quoi)

## Fichiers du Projet

```
2026-09-12_vault-secrets-management/
├── docker-compose.yml          # Infrastructure
├── init.sh                       # Script d'initialisation
├── vault-config.hcl             # Configuration Vault
├── database-setup.sql           # Setup PostgreSQL
├── examples/
│   ├── 01-auth-approle.sh       # AppRole authentication
│   ├── 02-read-static-secrets.sh # Lire des secrets
│   ├── 03-read-dynamic-creds.sh  # Lire des credentials dynamiques
│   └── 04-rotate-secrets.sh      # Rotation de secrets
└── README.md                     # Ce fichier
```

## Commandes Utiles

```bash
# Vérifier le status de Vault
vault status

# Lister les authentifications activées
vault auth list

# Lister les engines de secrets
vault secrets list

# Lister les audits
vault audit list

# Voir les logs Vault
docker logs vault-server

# Entrer en CLI interactif
vault login

# Déverrouiller Vault
vault unseal
```

## Exercices Supplémentaires

1. **Rotation automatique** : Configurer un script cron pour rotater les secrets
2. **Authentification AWS** : Utiliser AWS IAM pour l'authentification
3. **Secrets Version Control** : Utiliser `vault kv metadata` pour versionner
4. **Audit Avancé** : Parser les logs Vault pour créer des alertes
5. **Disaster Recovery** : Configurer un Vault en HA avec Raft backend

## Troubleshooting

```bash
# Vault n'est pas accessible
curl -v http://localhost:8200/v1/sys/health

# Container ne démarre pas
docker logs vault-server

# Permission denied sur les secrets
# Vérifier les policies : vault policy list / vault policy read <name>

# Dynamic credentials ne se créent pas
# Vérifier la connexion DB : vault write -force database/rotate-root/postgresql
```

## Pour Aller Plus Loin

- 📖 [Vault Documentation](https://www.vaultproject.io/docs)
- 🎓 [Vault Architecture](https://www.vaultproject.io/docs/internals/architecture)
- 🔐 [Dynamic Database Credentials](https://www.vaultproject.io/docs/secrets/databases)
- 🚀 [Production Hardening](https://www.vaultproject.io/docs/internals/security)

---

**Temps d'exécution estimé** : 2-4 heures (suivre les étapes + exercices)  
**Difficulté** : Intermédiaire  
**Prérequis de départ** : Docker, Bash, notions API REST
