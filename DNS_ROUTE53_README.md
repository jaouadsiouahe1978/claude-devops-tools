# Guide Complet DNS & Route53 AWS
**Infrastructure: Zone Sud-2, VPC 10.0.0.0/16, Clusters A/B, Bastion**

---

## Vue d'ensemble

Ce package contient un guide complet pour implémenter et gérer le DNS sur AWS Route53 pour l'infrastructure décrite (Zone Sud-2). Il comprend :

1. **Guide d'apprentissage** - Concepts DNS et Route53 depuis le début
2. **Configuration Terraform** - Infrastructure as Code pour Route53
3. **Scripts de validation** - Tests automatisés et monitoring
4. **Guide d'implémentation pratique** - Déploiement step-by-step
5. **Exemples JSON** - Cas d'usage courants pour changements batch

---

## Fichiers inclus

### Documentation

| Fichier | Description |
|---------|------------|
| `DNS_ROUTE53_LEARNING_GUIDE.md` | **COMMENCER ICI** - Guide complet DNS 101 + Route53 |
| `ROUTE53_IMPLEMENTATION_GUIDE.md` | Déploiement pratique step-by-step |
| `DNS_ROUTE53_README.md` | Ce fichier |

### Code Infrastructure

| Fichier | Description |
|---------|------------|
| `route53_complete_config.tf` | Configuration Terraform complète (7 sections) |
| `route53_terraform.tfvars.example` | Exemple de variables avec toutes les valeurs |

### Scripts de Validation

| Fichier | Description |
|---------|------------|
| `dns_validation_scripts.sh` | Suite de validation Bash (14 tests) |
| `dns_advanced_tests.py` | Tests avancés Python avec monitoring |
| `route53_examples.json` | 12 exemples de changements batch |

---

## Démarrage Rapide

### 1. Lire le guide d'apprentissage (15 min)

```bash
# Comprendre les concepts fondamentaux
cat DNS_ROUTE53_LEARNING_GUIDE.md

# Points clés:
# - Concepts DNS: zones, TTL, nameservers
# - Route53 sur AWS
# - Types de records (A, AAAA, CNAME, Alias, etc)
# - Health checks et routing policies
```

### 2. Préparation (30 min)

```bash
# Collecter les informations
aws elbv2 describe-load-balancers --region sa-east-2 \
  --query 'LoadBalancers[0].{DNS:DNSName,ZoneId:CanonicalHostedZoneId}'

aws ec2 describe-addresses --region sa-east-2 \
  --query 'Addresses[?Tags[?Key==`Name`]].PublicIp'

aws ec2 describe-vpcs --region sa-east-2 --query 'Vpcs[0].VpcId'

# Créer un dossier de travail
mkdir -p route53-dns && cd route53-dns
cp route53_complete_config.tf .
cp route53_terraform.tfvars.example terraform.tfvars
```

### 3. Configuration Terraform (30 min)

```bash
# Éditer terraform.tfvars avec vos valeurs
nano terraform.tfvars

# Initialiser
terraform init
terraform validate

# Planifier
terraform plan -out=tfplan

# Appliquer
terraform apply tfplan

# Récupérer les nameservers
terraform output nameservers
```

### 4. Configurer le registrar (GoDaddy) (10 min)

```
1. Connecter à https://www.godaddy.com/
2. My Products → Domains → domaine.com → Manage DNS
3. Copier les 4 nameservers Route53
4. Attendre 5-10 minutes
```

### 5. Tester (15 min)

```bash
# Tests basiques
./dns_validation_scripts.sh domaine.com production

# Tests avancés
python3 dns_advanced_tests.py --domain domaine.com --report text

# Vérifier propagation
dig api.domaine.com
dig admin.domaine.com
dig aden.domaine.com
```

**Temps total: ~2 heures pour déploiement complet**

---

## Architecture DNS Déployée

```
┌─────────────────────────────────────────────────────────────┐
│ ROUTE53 ZONE: domaine.com                                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ ✓ domaine.com (apex)                                        │
│   └─ Alias → ALB (203.0.113.42)                             │
│                                                               │
│ ✓ api.domaine.com                                           │
│   └─ Alias → ALB (weighted routing possible)                │
│      Health Check: HTTPS /health                             │
│      TTL: 300s (fast failover)                               │
│                                                               │
│ ✓ admin.domaine.com                                         │
│   └─ A Record → Bastion Elastic IP (203.0.113.50)           │
│      Health Check: TCP port 22                               │
│      TTL: 3600s (stable)                                     │
│                                                               │
│ ✓ aden.domaine.com                                          │
│   └─ A Record → External Partner (203.0.113.99)             │
│      TTL: 300s (peut changer)                                │
│                                                               │
│ ✓ PRIVATE ZONE: internal.domaine.com                        │
│   └─ VPC Resolver (10.0.0.0/16 only)                        │
│   ├─ internal.domaine.com → 10.0.20.50                      │
│   ├─ db.internal.domaine.com → 10.0.10.20 (RDS)            │
│   └─ cache.internal.domaine.com → 10.0.11.30 (Redis)       │
│                                                               │
│ ✓ MX Records (optionnel)                                    │
│   └─ Mail routing (Google Workspace, etc)                   │
│                                                               │
│ ✓ TXT Records                                               │
│   ├─ SPF: v=spf1 include:_spf.google.com ~all               │
│   ├─ DKIM: v=DKIM1; k=rsa; p=...                            │
│   └─ DMARC: v=DMARC1; p=quarantine                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Types de tests inclus

### Tests Bash (dns_validation_scripts.sh)

```bash
./dns_validation_scripts.sh domaine.com production
```

**14 vérifications:**
1. ✓ Credentials AWS valides
2. ✓ Hosted zone existe
3. ✓ Records DNS existent
4. ✓ Zone privée configurée
5. ✓ Health checks actifs
6. ✓ Résolution DNS fonctionne
7. ✓ Propagation globale vérifiée
8. ✓ Connectivité endpoints
9. ✓ Reverse DNS
10. ✓ Certificats SSL/TLS
11. ✓ Valeurs TTL appropriées
12. ✓ CloudWatch alarms
13. ✓ DNSSEC status
14. ✓ Query logging

**Output:** Rapport texte avec PASS/FAIL détaillé

### Tests Python (dns_advanced_tests.py)

```bash
python3 dns_advanced_tests.py --domain domaine.com --report json
python3 dns_advanced_tests.py --domain domaine.com --monitor --interval 300
```

**Fonctionnalités:**
- Résolution multi-threaded vers tous les DNS publics
- Mesure de latence (ms)
- Tests health checks
- CloudWatch monitoring
- Rapports JSON/texte
- Mode monitoring continu

---

## Cas d'usage courants

### Déploiement canary (A/B testing)

```bash
# Déployer nouvelle version à 10% du trafic
# Voir route53_examples.json > Example 3
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123 \
  --change-batch file://canary-deployment.json

# Augmenter progressivement: 10% → 25% → 50% → 100%
```

### Failover d'urgence

```bash
# Si ALB primaire down, basculer à secondaire
# Réduit TTL à 60s d'abord
terraform apply -var-file="terraform.tfvars" \
  -target='aws_route53_record.api_weighted'

# Puis changer l'IP ALB et attendre 60s
```

### Migration DNS (registrar change)

```bash
# 1. Créer zone Route53 identique
# 2. Réduire TTL à 300s une semaine avant
# 3. Copier NS vers nouveau registrar
# 4. Attendre propagation
# 5. Basculer
# 6. Garder ancien registrar 30 jours (backup)
```

### Maintenance serveur

```bash
# Bastion maintenance = réduire TTL + basculer
terraform apply -var-file="terraform-maintenance.tfvars"
# TTL: 60, admin IP → secondaire
# Maintenance
# terraform apply -var-file="terraform.tfvars"
# Restaurer normal
```

---

## Monitoring & Alertes

### CloudWatch Alarms (créées par Terraform)

```bash
# Alarm ALB health check
aws cloudwatch describe-alarms \
  --alarm-names "route53-alb-health-check-failed"

# Alarm Bastion health check
aws cloudwatch describe-alarms \
  --alarm-names "route53-bastion-health-check-failed"
```

### Cron job pour tests réguliers

```bash
# Tester chaque heure
0 * * * * /path/to/dns_validation_scripts.sh domaine.com production

# Tester tous les 15 minutes
*/15 * * * * python3 /path/to/dns_advanced_tests.py --domain domaine.com
```

### SNS Notifications

```bash
# Créer topic
aws sns create-topic --name route53-alerts

# Souscrire
aws sns subscribe \
  --topic-arn arn:aws:sns:sa-east-2:ACCOUNT_ID:route53-alerts \
  --protocol email \
  --notification-endpoint admin@domaine.com
```

---

## Troubleshooting rapide

| Problème | Commande de diagnostic |
|----------|----------------------|
| Records ne résolvent pas | `dig api.domaine.com` + `dig @ns-123.awsdns-45.com api.domaine.com` |
| NS records ne mis à jour | `dig ns domaine.com` + vérifier GoDaddy |
| Health check échoue | `curl https://api.domaine.com/health` + vérifier SG |
| TTL trop haut | `aws route53 list-resource-record-sets --hosted-zone-id Z123` |
| Propagation lente | Attendre 24-48h ou voir whatsmydns.net |
| Certificat invalide | `openssl s_client -connect api.domaine.com:443` |

---

## Best Practices (Résumé)

### Avant Production
- [ ] TTL court (300s) pour endpoints dynamiques
- [ ] Health checks activés pour tous les records critiques
- [ ] Alias records pour ALB/CloudFront (pas CNAME)
- [ ] Nameservers copiés vers registrar
- [ ] Attendre 24-48h propagation

### En Production
- [ ] Monitoring CloudWatch actif
- [ ] Alarms SNS configurées
- [ ] Cron job pour tests horaires
- [ ] Backup état Terraform
- [ ] Documentation mise à jour
- [ ] Runbook pour failover manuel

### Sécurité
- [ ] DNSSEC enabled (si applicable)
- [ ] Query logging enabled (CloudWatch Logs)
- [ ] IAM roles restrictifs (pas d'accès console)
- [ ] Terraform state stocké en S3 + chiffrement
- [ ] Audit trail via CloudTrail

---

## Configuration par environnement

### Development

```hcl
environment = "development"
enable_health_checks = false  # Optionnel
ttl_values = 60              # Changements rapides
```

### Staging

```hcl
environment = "staging"
enable_health_checks = true
ttl_values = 300             # Balance perf/agility
```

### Production

```hcl
environment = "production"
enable_health_checks = true  # Mandatory
ttl_values = 300             # ALB/Bastion changent rarement
enable_dnssec = true         # Sécurité
enable_query_logging = true  # Audit
```

---

## Coûts estimés

| Ressource | Coût mensuel |
|-----------|------------|
| Hosted Zone publique | $0.50 |
| Hosted Zone privée | $1.00 |
| Health Check ALB | $0.50 |
| Health Check Bastion | $0.50 |
| 10M DNS queries | $4.00 |
| **Total** | **$6.50** |

*Note: Alias queries vers AWS resources = gratuit*

---

## Étapes suivantes

### Immédiatement
1. Lire `DNS_ROUTE53_LEARNING_GUIDE.md` (15 min)
2. Préparer informations d'infrastructure (30 min)
3. Exécuter `ROUTE53_IMPLEMENTATION_GUIDE.md` (2 heures)

### Première semaine
- [ ] Tests de résolution réussis
- [ ] Propagation DNS vérifiée
- [ ] Health checks HEALTHY
- [ ] Alarms CloudWatch activées
- [ ] Documentation équipe mise à jour

### Premier mois
- [ ] Monitoring continu actif
- [ ] Aucun incident DNS
- [ ] Coûts validés
- [ ] Runbook failover testé

---

## Support et Ressources

### AWS Documentation
- [Route53 User Guide](https://docs.aws.amazon.com/route53/)
- [Health Checks](https://docs.aws.amazon.com/route53/latest/developerguide/health-checks-types.html)
- [Routing Policies](https://docs.aws.amazon.com/route53/latest/developerguide/routing-policy.html)

### Outils DNS
- [DNS Propagation Checker](https://www.whatsmydns.net/)
- [DNS Toolbox](https://mxtoolbox.com/)
- [Zonemaster](https://zonemaster.net/)

### Terraform
- [AWS Provider Route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)
- [Terraform State Management](https://www.terraform.io/language/state)

---

## Historique des versions

| Version | Date | Changements |
|---------|------|------------|
| 1.0 | Août 2026 | Version initiale - guide complet |
| - | - | Incluant Terraform, validation, exemples |

---

## Contacts & Support

**Infrastructure DevOps Team**
- Guide créé pour formation Jaouad
- Environnement: AWS Zone Sud-2
- Infrastructure: Terraform + Route53

**Pour plus d'aide:**
- Voir troubleshooting dans `ROUTE53_IMPLEMENTATION_GUIDE.md`
- Consulter `route53_examples.json` pour cas d'usage
- Exécuter `dns_validation_scripts.sh` pour diagnostic

---

## License & Usage

Ces ressources sont destinées à la formation et au déploiement DNS interne.
Adapter au cas par cas avec vos valeurs de production.

**Créé pour formation AWS DevOps - Août 2026**
