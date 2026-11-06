# Configuration des Secrets GitHub

## 🔐 Sécurité des Secrets

- **Cryptés au repos** : Utilise AES-256-GCM
- **Pas dans les logs** : GitHub masque automatiquement
- **Scope par environment** : Séparé par dev/staging/prod
- **Audit trail** : Qui a accédé aux secrets (log)

## 📋 Secrets Requis

### Secrets Globaux (Actions)

Aller dans : **GitHub Repo > Settings > Secrets and variables > Actions**

#### 1. DOCKER_REGISTRY_USER
```
Clé: DOCKER_REGISTRY_USER
Valeur: votre-username-dockerhub
```

Obtenir :
```bash
# Créer un account Docker Hub
# https://hub.docker.com
# Utiliser le username
```

#### 2. DOCKER_REGISTRY_PASSWORD
```
Clé: DOCKER_REGISTRY_PASSWORD
Valeur: votre-token-dockerhub
```

Obtenir :
```bash
# Docker Hub > Settings > Security > New Access Token
# Scopes: Read & Write
# Copier le token généré
```

#### 3. SLACK_WEBHOOK
```
Clé: SLACK_WEBHOOK
Valeur: https://hooks.slack.com/services/...
```

Obtenir :
```
1. Aller sur https://api.slack.com/apps
2. Create New App > From scratch
3. App name: "GitHub Actions"
4. Développement sur workspace
5. Incoming Webhooks > ON
6. Add New Webhook to Workspace
7. Sélectionner channel #devops (ou autre)
8. Copier Webhook URL
```

### Secrets par Environnement

#### Environnement: `staging`

**Aller dans**: Settings > Environments > staging > Environment secrets

```
KUBE_CONFIG_STAGING
Valeur: 
  cat ~/.kube/config-staging | base64 -w 0
```

#### Environnement: `production`

**Aller dans**: Settings > Environments > production > Environment secrets

```
KUBE_CONFIG_PROD
Valeur:
  cat ~/.kube/config-prod | base64 -w 0
```

## 🔑 Comment Obtenir Les Secrets

### Docker Hub Access Token

```bash
# 1. Login sur https://hub.docker.com
# 2. Cliquer sur profil > Settings > Security
# 3. Cliquer "New Access Token"
# 4. Name: "github-actions-token"
# 5. Permissions: Read & Write
# 6. Generate
# 7. Copier le token
# 8. Ne pas le perdre (ne peut pas le retvoir après)
```

### Kubeconfig Encoded

```bash
# Pour Kubernetes staging
cat ~/.kube/config-staging | base64 -w 0
# Output: Mxyz... (très long)

# Pour Kubernetes production
cat ~/.kube/config-prod | base64 -w 0
# Output: Nxyz... (très long)
```

Puis copier le output complet (base64).

### Slack Webhook

```
1. Créer une app Slack:
   https://api.slack.com/apps
   
2. "Create New App" > "From scratch"
   Name: "GitHub Actions"
   Workspace: Select your workspace

3. Sur la sidebar: "Incoming Webhooks"

4. Activer: Toggle "Activate Incoming Webhooks" ON

5. "Add New Webhook to Workspace"
   Select Channel: #devops (ou #general)
   Allow

6. Copier la Webhook URL:
   https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX
```

## 🔒 Format des Secrets

### KUBE_CONFIG_STAGING/PROD

**Format** : Base64 encoded kubeconfig

```yaml
# Original kubeconfig:
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://api.staging-cluster.com
  name: staging-cluster
...

# Converti en base64:
YXBpVmVyc2lvbjogdjEKY2x1c3RlcnM6Ci0gY2x1c3RlcjoKI... [très long]
```

**Utilisation en workflow**:
```bash
echo "${{ secrets.KUBE_CONFIG_STAGING }}" | base64 -d > /tmp/kubeconfig
export KUBECONFIG=/tmp/kubeconfig
kubectl get nodes
```

### DOCKER_REGISTRY_PASSWORD

**Format** : Access Token (pas le password)

```
Valeur: dckr_pat_xxxxxxxxxxxxx
```

**Utilisation en workflow**:
```yaml
uses: docker/login-action@v3
with:
  username: ${{ secrets.DOCKER_REGISTRY_USER }}
  password: ${{ secrets.DOCKER_REGISTRY_PASSWORD }}
```

### SLACK_WEBHOOK

**Format** : URL complète

```
https://hooks.slack.com/services/T12345678/B12345678/XXXXXXXXXXXXXXXXXXXX
```

**Utilisation en workflow**:
```yaml
uses: slackapi/slack-github-action@v1
with:
  payload: |
    { "text": "Message" }
env:
  SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## ✅ Vérifier Les Secrets

### Test de Connexion Docker Hub

```bash
# Localement d'abord
docker login -u $DOCKER_USER -p $DOCKER_TOKEN
# Résultat: Login Succeeded
```

### Test de Connexion Kubernetes

```bash
# Localement
export KUBECONFIG=/path/to/kubeconfig
kubectl get nodes
# Résultat: Liste des nodes
```

### Test de Webhook Slack

```bash
curl -X POST https://hooks.slack.com/services/... \
  -H 'Content-Type: application/json' \
  -d '{"text":"Test from terminal"}'
  
# Résultat: Le message apparaît dans Slack
```

## 📝 Checklist Configuration

- [ ] Docker Hub account créé
- [ ] Access token Docker Hub généré
- [ ] DOCKER_REGISTRY_USER ajouté à GitHub secrets
- [ ] DOCKER_REGISTRY_PASSWORD ajouté à GitHub secrets
- [ ] Slack workspace access
- [ ] Slack app créé
- [ ] Slack webhook généré
- [ ] SLACK_WEBHOOK ajouté à GitHub secrets
- [ ] Kubeconfig staging préparé
- [ ] KUBE_CONFIG_STAGING ajouté au staging environment
- [ ] Kubeconfig production préparé
- [ ] KUBE_CONFIG_PROD ajouté au production environment
- [ ] Test: Docker login fonctionne
- [ ] Test: kubectl works with kubeconfig
- [ ] Test: Slack webhook reçoit messages

## 🚨 Sécurité - Ne Jamais Faire

❌ **Ne jamais** mettre les secrets en plaintext dans le code
```
MAUVAIS:
  password: "abc123def456"
  token: "dckr_pat_xyz..."
```

❌ **Ne jamais** committer les kubeconfigs
```
MAUVAIS:
  git add ~/.kube/config
  git commit -m "Add kubeconfig"
```

❌ **Ne jamais** exposer les secrets dans les logs
```
MAUVAIS:
  echo "Password is: $PASSWORD"
  DEBUG: print(token)
```

✅ **Toujours** utiliser les secrets GitHub
```
BON:
  password: ${{ secrets.DB_PASSWORD }}
  token: ${{ secrets.DOCKER_TOKEN }}
```

✅ **Toujours** base64 encoder les fichiers sensibles
```
BON:
  cat kubeconfig | base64 -w 0
  echo "..." > secret
  chmod 600 secret
```

## 🔄 Rotation des Secrets

### Changer un Secret

```
1. Générer un nouveau secret (ex: nouveau token Docker)
2. GitHub > Settings > Secrets > Éditer le secret existant
3. Copier nouvelle valeur
4. Update
5. Ancien secret reste actif jusqu'au prochain workflow
```

### Retirer un Secret

```
1. GitHub > Settings > Secrets > Sélectionner le secret
2. Cliquer "Delete"
3. Confirmé
4. Workflows n'y auront plus accès (vont échouer)
```

## 📊 Audit des Secrets

### Voir qui a utilisé les secrets

```
GitHub > Settings > Security > Audit log

Search: "secret_accessed"
Voir:
  - Qui
  - Quand
  - Quel workflow
  - Quel secret
```

### Logs des Workflows

```
GitHub > Actions > Sélectionner workflow
"Display name of current job" > Voir les steps
(Les secrets sont masquées dans les logs *** )
```

## 🎯 Best Practices

1. **Minimum Privilèges** : Utiliser des tokens avec permissions minimales
2. **Rotation Régulière** : Changer les tokens tous les 3-6 mois
3. **Separate par Env** : Dev tokens ≠ Prod tokens
4. **Audit** : Monitorer l'accès aux secrets
5. **Revoke Immédiatement** : Si token compromis
6. **Documentation** : Garder une liste des secrets
7. **No Expiration** : Sauf pour CI/CD (ils doivent être renouvelés)

## 📞 Troubleshooting

### Secret pas trouvé
```
Error: Secret not found: DOCKER_TOKEN

Solution:
1. Vérifier le nom exact du secret (case-sensitive)
2. Vérifier dans le bon environment/scope
3. Vérifier le workflow a l'accès
```

### Docker login échoue
```
Error: denied: invalid credentials

Solutions:
1. Vérifier username/password corrects
2. Vérifier pas d'espace whitespace
3. Régénérer le token si expiré
```

### Kubernetes connection échoue
```
Error: Unable to connect to the server

Solutions:
1. Vérifier kubeconfig est bien base64 encoded
2. Vérifier kubeconfig n'a pas expiré
3. Vérifier adresse API du cluster
4. Vérifier certificats sont valides
```

---

**Pour des questions** : Consulter la documentation GitHub Secrets :
https://docs.github.com/en/actions/security-guides/encrypted-secrets
