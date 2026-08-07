# Checklist Complète DNS Route53
**Infrastructure: Zone Sud-2, VPC 10.0.0.0/16, Clusters A/B, Bastion**

---

## PHASE 1: PRÉPARATION (Avant toute action)

### Information gathering
- [ ] ALB DNS Name collecté: `___________________`
- [ ] ALB Zone ID collecté: `___________________`
- [ ] Bastion Elastic IP collecté: `___________________`
- [ ] VPC ID collecté: `___________________`
- [ ] Domaine enregistré chez registrar: `___________________`
- [ ] Accès AWS Console disponible: `Yes / No`
- [ ] Accès GoDaddy/Registrar disponible: `Yes / No`

### Outils & Permissions
- [ ] AWS CLI v2 installé: `aws --version`
- [ ] Terraform 1.0+ installé: `terraform --version`
- [ ] dnsutils/dig installé: `dig --version`
- [ ] jq installé: `jq --version`
- [ ] Permissions Route53 IAM confirmées
- [ ] Permissions CloudWatch confirmées

### Documentation
- [ ] Guide d'apprentissage DNS lu (DNS_ROUTE53_LEARNING_GUIDE.md)
- [ ] Architecture infrastructure comprise
- [ ] Flux de trafic DNS compris
- [ ] Types de records nécessaires identifiés

---

## PHASE 2: TERRAFORM SETUP (2h environ)

### Initialisation
- [ ] Dossier de travail créé: `mkdir -p route53-dns && cd route53-dns`
- [ ] Fichiers copiés:
  - [ ] `route53_complete_config.tf`
  - [ ] `route53_terraform.tfvars.example`
  - [ ] `dns_validation_scripts.sh`
  - [ ] `dns_advanced_tests.py`
- [ ] Git initialisé: `git init`
- [ ] .gitignore créé (terraform.tfvars, *.tfstate*)

### Configuration terraform.tfvars
- [ ] `domain_name = "domaine.com"` (ajusté)
- [ ] `alb_dns_name = "..."` (ALB réel)
- [ ] `alb_zone_id = "..."` (Z7KQB4TC7K336OM4F for sa-east-2)
- [ ] `bastion_elastic_ip = "..."` (Bastion réel)
- [ ] `vpc_id = "vpc-..."` (VPC réel)
- [ ] `aws_region = "sa-east-2"` (confirmé)
- [ ] `environment = "production"` (ou dev/staging)
- [ ] `enable_health_checks = true` (recommandé)

### Terraform Validation
- [ ] `terraform init` exécuté avec succès
- [ ] `terraform fmt -check -recursive` passed
- [ ] `terraform validate` passed
- [ ] `terraform plan -out=tfplan` généré sans erreurs
- [ ] Plan reviewé pour ressources correctes:
  - [ ] 1 hosted zone publique
  - [ ] 1 hosted zone privée
  - [ ] 5+ records (apex, api, admin, external, etc)
  - [ ] 2 health checks (ALB + Bastion)
  - [ ] 2 CloudWatch alarms

### Terraform Apply
- [ ] `terraform apply tfplan` exécuté avec succès
- [ ] Pas d'erreurs ou warnings critiques
- [ ] Outputs affichés correctement:
  - [ ] `hosted_zone_id` visible
  - [ ] `nameservers` visible (4 NS)
  - [ ] `dns_configuration` visible
- [ ] Terraform state sauvegardé: `cp terraform.tfstate terraform.tfstate.backup.$(date +%s)`

### Terraform Outputs Documentés
- [ ] Hosted Zone ID: `Z___________________`
- [ ] Nameserver 1: `ns-___.awsdns-__.com`
- [ ] Nameserver 2: `ns-___.awsdns-__.us`
- [ ] Nameserver 3: `ns-___.awsdns-__.co.uk`
- [ ] Nameserver 4: `ns-___.awsdns-__.com`

---

## PHASE 3: REGISTRAR CONFIGURATION (GoDaddy)

### Accès registrar
- [ ] Connecté à https://www.godaddy.com/
- [ ] Email de connexion: `___________________`
- [ ] MFA/2FA activé (si disponible)

### Mise à jour Nameservers
- [ ] Aller à: My Products → Domains → domaine.com
- [ ] Cliquer sur: "Manage DNS"
- [ ] Cliquer sur: "Change Nameservers"
- [ ] 4 nameservers Route53 copiés:
  - [ ] NS 1: `ns-___.awsdns-__.com`
  - [ ] NS 2: `ns-___.awsdns-__.us`
  - [ ] NS 3: `ns-___.awsdns-__.co.uk`
  - [ ] NS 4: `ns-___.awsdns-__.com`
- [ ] Changements sauvegardés
- [ ] Confirmation reçue (email)

### Attendre Propagation
- [ ] Attendre 5-10 minutes minimum
- [ ] Vérifier via: `dig ns domaine.com`
- [ ] Résultat doit montrer NS records Route53 (pas GoDaddy)

---

## PHASE 4: VALIDATION DNS (1h environ)

### Tests Basiques (AWS CLI)
- [ ] Zone créée: `aws route53 get-hosted-zone --id Z___ | jq`
- [ ] Records existent: `aws route53 list-resource-record-sets --hosted-zone-id Z___`
- [ ] Apex record: `aws route53 list-resource-record-sets ... | grep domaine.com`
- [ ] API record: `aws route53 list-resource-record-sets ... | grep api.domaine.com`
- [ ] Admin record: `aws route53 list-resource-record-sets ... | grep admin.domaine.com`

### Tests Résolution DNS (dig)
- [ ] Apex: `dig domaine.com` → résout correctement
- [ ] API: `dig api.domaine.com` → résout correctement
- [ ] Admin: `dig admin.domaine.com` → résout correctement
- [ ] External: `dig aden.domaine.com` → résout correctement
- [ ] Nameserver test: `dig @ns-___.awsdns-__.com api.domaine.com` → répond

### Tests Propagation Globale
- [ ] Google: `dig @8.8.8.8 api.domaine.com` → résout
- [ ] Cloudflare: `dig @1.1.1.1 api.domaine.com` → résout
- [ ] OpenDNS: `dig @208.67.222.222 api.domaine.com` → résout
- [ ] Quad9: `dig @9.9.9.9 api.domaine.com` → résout
- [ ] WhatsDNS check: https://www.whatsmydns.net/ (tous les resolvers OK)

### Tests via Script Bash
- [ ] `chmod +x dns_validation_scripts.sh`
- [ ] `./dns_validation_scripts.sh domaine.com production` exécuté
- [ ] Tous les tests PASS (ou WARNING acceptable):
  - [ ] ✓ AWS credentials valid
  - [ ] ✓ Hosted zone found
  - [ ] ✓ DNS records validated
  - [ ] ✓ Private zone found
  - [ ] ✓ Health checks found
  - [ ] ✓ DNS resolution works
  - [ ] ✓ Propagation verified
  - [ ] ✓ Connectivity OK
  - [ ] ✓ TTL values checked
  - [ ] ✓ CloudWatch alarms found
- [ ] Rapport généré: `/tmp/dns_validation_report_*`

### Tests via Script Python
- [ ] `pip install boto3 requests`
- [ ] `python3 dns_advanced_tests.py --domain domaine.com --report text`
- [ ] Résultats affichés sans erreurs
- [ ] Toutes les résolutions réussies (all resolvers)
- [ ] Health checks status affichés
- [ ] CloudWatch alarms listés

---

## PHASE 5: HEALTH CHECKS (30min)

### Vérifier ALB Health Check
- [ ] Health check créé par Terraform: `aws route53 list-health-checks`
- [ ] Type: HTTPS ✓
- [ ] Path: /health ✓
- [ ] Port: 443 ✓
- [ ] Interval: 30s ✓
- [ ] Status: HEALTHY
- [ ] Endpoint disponible: `curl https://api.domaine.com/health`

### Vérifier Bastion Health Check
- [ ] Health check créé par Terraform: `aws route53 list-health-checks`
- [ ] Type: TCP ✓
- [ ] Port: 22 ✓
- [ ] Status: HEALTHY
- [ ] SSH accessible: `ssh -v admin@admin.domaine.com "echo OK"`

### Vérifier CloudWatch Alarms
- [ ] Alarm ALB exists: `aws cloudwatch describe-alarms --alarm-names route53-alb-health-check-failed`
- [ ] State: OK (pas d'alarm)
- [ ] Alarm Bastion exists: `aws cloudwatch describe-alarms --alarm-names route53-bastion-health-check-failed`
- [ ] State: OK (pas d'alarm)

---

## PHASE 6: TESTS D'CONNECTIVITÉ (30min)

### Test HTTP/HTTPS
- [ ] Accès via API: `curl -v https://api.domaine.com` → OK (pas de 5xx)
- [ ] Accès via Apex: `curl -v https://domaine.com` → OK
- [ ] Certificat valide: `openssl s_client -connect api.domaine.com:443`
- [ ] Status: "verify OK" ✓

### Test SSH (Bastion)
- [ ] SSH accessible: `ssh admin@admin.domaine.com`
- [ ] Port 22 ouvert via SG
- [ ] Authentification réussie

### Test Services Internes
- [ ] Si accès EC2: `ssh ec2-user@<cluster-ip>`
- [ ] Résolution interne: `nslookup internal.domaine.com`
- [ ] DB accessible: `nslookup db.internal.domaine.com`
- [ ] Cache accessible: `nslookup cache.internal.domaine.com`

### Test Service Externe
- [ ] Accès: `curl -v https://aden.domaine.com` (ou valider IP)
- [ ] Endpoint du partenaire accessible

---

## PHASE 7: PRODUCTION READINESS (30min)

### Documentation
- [ ] Toutes les ressources documentées (spreadsheet ou wiki)
- [ ] Records DNS avec TTL documentés
- [ ] Health checks avec seuils documentés
- [ ] IPs et hostnames sauvegardés (emergency backup)
- [ ] Runbook failover écrit
- [ ] Runbook maintenance écrit

### Monitoring Setup
- [ ] CloudWatch alarms vérifiés
- [ ] SNS topic créé pour alertes
- [ ] Email subscription confirmée
- [ ] Test alert: `aws sns publish --topic-arn arn:aws:sns:sa-east-2:ACCOUNT:route53-alerts --message "Test"`

### Backup & Recovery
- [ ] Terraform state backupé: `cp terraform.tfstate terraform.tfstate.backup`
- [ ] Git commit initial: `git add . && git commit -m "Initial Route53 setup"`
- [ ] Zone exported (AWS CLI): `aws route53 list-resource-record-sets --hosted-zone-id Z___ > zone-backup.json`

### Security
- [ ] IAM permissions vérifiés (least privilege)
- [ ] CloudTrail logging enabled (capture tous les changements DNS)
- [ ] Terraform backend S3 configuré (pour multi-user)
- [ ] terraform.tfvars dans .gitignore
- [ ] Aucun secret en plaintext

### Cost Review
- [ ] Coûts estimés acceptés ($6-8/mois)
- [ ] Budget alert configuré (AWS Budgets)
- [ ] Pas de ressources non-utilisées

---

## PHASE 8: MONITORING CONTINU (Ongoing)

### Daily
- [ ] Health checks vérifiés (0 UNHEALTHY)
- [ ] Pas d'alarms CloudWatch actives
- [ ] Logs DNS vérifiés (pas d'erreurs)

### Weekly
- [ ] `./dns_validation_scripts.sh domaine.com production` exécuté
- [ ] Tous tests PASS
- [ ] Propagation globale vérifiée
- [ ] Performance TTL acceptable

### Monthly
- [ ] `python3 dns_advanced_tests.py --domain domaine.com --report json > report.json`
- [ ] Rapport analysé pour tendances
- [ ] Infrastructure review
- [ ] Coûts revus vs budget

### Quarterly (3 months)
- [ ] Tests de failover réels:
  - [ ] Arrêter ALB primaire → vérifier failover
  - [ ] Arrêter Bastion → vérifier failover
  - [ ] Mesurer temps de failover (< 5 min target)
- [ ] Disaster recovery test (spin-up from backup)
- [ ] Terraform state integrity check
- [ ] Documentation update

---

## PHASE 9: TROUBLESHOOTING RAPIDE

### Si NS records ne mis à jour
```bash
Symptôme: dig ns domaine.com retourne les anciens NS
□ Vérifier GoDaddy (page mise à jour?)
□ Attendre 5-10 minutes supplémentaires
□ Vider cache DNS: sudo dscacheutil -flushcache (macOS)
□ Tester avec resolver différent: dig @8.8.8.8 ns domaine.com
□ Si toujours rien après 1h, contacter GoDaddy support
```

### Si API record ne résout pas
```bash
Symptôme: dig api.domaine.com = NXDOMAIN
□ Vérifier record existe: aws route53 list-resource-record-sets
□ Tester directement: dig @ns-___.awsdns-__.com api.domaine.com
□ Vérifier ALB existe: aws elbv2 describe-load-balancers
□ Vérifier ALB DNS name correct: terraform output alb_dns_name
□ Recréer record: terraform taint aws_route53_record.api_weighted && terraform apply
```

### Si Health check échoue
```bash
Symptôme: Health check status = UNHEALTHY
□ Tester endpoint: curl https://api.domaine.com/health
□ Vérifier ALB SG: port 443 ouvert depuis 0.0.0.0/0
□ Vérifier path /health existe sur app
□ Vérifier ALB target groupe: instances running + healthy
□ Augmenter failure threshold temporairement (test en cours?)
□ Attendre 60s pour retry automatique
```

### Si TTL change trop lent
```bash
Symptôme: Changement DNS prend > 1h pour propager
□ Vérifier TTL actuel: aws route53 list-resource-record-sets | grep TTL
□ Réduire TTL temporairement: terraform apply -var ttl=60
□ Attendre 60s après changement
□ Augmenter à nouveau: terraform apply -var ttl=300
```

---

## PHASE 10: INCIDENT RESPONSE

### Procédure Escalade Rapide

**SCENARIO: API.DOMAINE.COM DOWN**

```
T+0min:
□ Health check alert reçu via SNS
□ Vérifier: curl https://api.domaine.com (confirmé down)
□ Vérifier ALB: aws elbv2 describe-target-health (check targets)

T+2min (Option A: ALB est OK mais targets down):
□ Redémarrer instances: aws ec2 reboot-instances --instance-ids i-xxxxx
□ OU scale up ASG: aws autoscaling set-desired-capacity --asg-name xxx --desired-capacity 2
□ Attendre health check refresh (30s)

T+5min (Option B: ALB lui-même est down):
□ Basculer à ALB secondaire:
   terraform apply -var-file="terraform-failover.tfvars"
□ Ou changement manual: aws route53 change-resource-record-sets --change-batch file://failover.json
□ TTL déjà réduit à 60s → propagation < 1min

T+10min:
□ Investiguer ALB failure (logs, SG, etc)
□ Notifier team pour investigation root cause
□ Documenter incident
```

### Commandes d'urgence

```bash
# Vérifier état global
./dns_validation_scripts.sh domaine.com production

# Forcer refresh health check
aws route53 get-health-check-status --health-check-id hc-xxxxx

# Changer TTL pour failover rapide
# (voir PHASE 9 > Si TTL change trop lent)

# Basculer à IP secondaire (si existe)
aws route53 change-resource-record-sets --hosted-zone-id Z___ \
  --change-batch '{
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.domaine.com",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [{"Value": "203.0.113.51"}]
      }
    }]
  }'

# Communiquer status à la team
aws sns publish --topic-arn arn:aws:sns:sa-east-2:ACCOUNT:route53-alerts \
  --message "API DNS failover activated - investigating root cause"
```

---

## PHASE 11: SIGN-OFF & CLOSEOUT

### Validation Finale
- [ ] Toutes phases complétées
- [ ] Tous tests PASS
- [ ] Documentation complète
- [ ] Monitoring actif
- [ ] Incidents testés & documentés

### Approvals
- [ ] Infrastructure team approval: `_____________ Date: ___`
- [ ] Security team approval: `_____________ Date: ___`
- [ ] DNS team approval: `_____________ Date: ___`
- [ ] DevOps lead approval: `_____________ Date: ___`

### Post-Launch
- [ ] Email notification envoyée à la team
- [ ] Documentation partagée (wiki/confluence)
- [ ] Runbooks accessibles à tous
- [ ] Training session programmée (optionnel)
- [ ] 30-day review planifié

### Archivage
- [ ] Terraform code versionné en Git
- [ ] État sauvegardé: `terraform.tfstate.backup`
- [ ] Zone export JSON: `zone-backup.json`
- [ ] Toute documentation centralisée
- [ ] Contacts d'escalade documentés

---

## Temps Estimé par Phase

| Phase | Durée | Notes |
|-------|-------|-------|
| Phase 1: Préparation | 1 heure | Collecte info, outils |
| Phase 2: Terraform | 2 heures | Setup, validation, apply |
| Phase 3: Registrar | 30 min | + 5-10 min attente |
| Phase 4: Validation | 1 heure | Tests complets |
| Phase 5: Health Checks | 30 min | Vérification |
| Phase 6: Connectivité | 30 min | Tests connectivity |
| Phase 7: Prod Readiness | 30 min | Documentation, backup |
| Phase 8-11: Ongoing | Ongoing | Monitoring continu |
| **TOTAL** | **~6 heures** | + 24-48h attente propagation |

---

## Contact & Support

**Infrastructure Team**
- Email: infrastructure@domaine.com
- Slack: #dns-route53
- Escalation: On-call engineer

**Ressources de référence**
- `DNS_ROUTE53_LEARNING_GUIDE.md` - Concepts
- `ROUTE53_IMPLEMENTATION_GUIDE.md` - Détails
- `route53_examples.json` - Cas d'usage
- `dns_advanced_tests.py` - Diagnostic avancé

---

**Créé:** Août 2026 | **Dernière mise à jour:** [DATE] | **Version:** 1.0
