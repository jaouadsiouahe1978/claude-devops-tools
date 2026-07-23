# Configuration GitHub - Secrets et Environments

## 🔐 Configuration des Secrets Repository

```bash
# Via CLI GitHub
gh secret set API_KEY --body "votre-clé"
gh secret set DB_PASSWORD --body "votre-password"
gh secret set DEPLOY_KEY < ~/.ssh/id_rsa
gh secret set APP_URL --body "https://staging.example.com"

# Lister les secrets
gh secret list
```

## 🌍 Configuration des Environments

### Créer un Environment Staging
1. Settings → Environments → New environment
2. Nom: `staging`
3. Ajouter secrets:
   - APP_URL: https://staging.example.com
   - API_KEY: clé-staging
   - DB_PASSWORD: password-staging

### Créer un Environment Production
1. Settings → Environments → New environment
2. Nom: `production`
3. ✅ Require reviewers: 2 approvers
4. ✅ Deployment branches: main only
5. Ajouter secrets:
   - APP_URL: https://prod.example.com
   - API_KEY: clé-prod
   - DB_PASSWORD: password-prod

## 📋 Secrets vs Variables

| Type | Masqué | Use |
|------|--------|-----|
| **Secrets** | ✅ Oui | API keys, passwords, tokens |
| **Variables** | ❌ Non | Config non-sensible, ENVIRONMENT |

```yaml
# Secrets (chiffré)
run: ./deploy.sh
env:
  API_KEY: ${{ secrets.API_KEY }}

# Variables (plaintext)
run: echo ${{ vars.ENVIRONMENT }}
```

## ✅ Checklist de Sécurité

- [ ] Tous les secrets configurés en GitHub (pas .env)
- [ ] Production environment avec approvals
- [ ] .gitignore contient .env et *.key
- [ ] Secrets masqués dans les logs
- [ ] Audit logs vérifiés

## 📚 Ressources

- [GitHub Secrets Docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments)
