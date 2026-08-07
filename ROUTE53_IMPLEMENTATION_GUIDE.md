# Guide Pratique : Implémentation Route53
**Déploiement DNS pour infrastructure AWS (Zone Sud-2, VPC, Clusters A/B, Bastion)**

---

## Table des matières

1. [Prérequis](#prérequis)
2. [Étape 1 : Préparation](#étape-1-préparation)
3. [Étape 2 : Configuration Terraform](#étape-2-configuration-terraform)
4. [Étape 3 : Configuration du Registrar](#étape-3-configuration-du-registrar)
5. [Étape 4 : Tests et Validation](#étape-4-tests-et-validation)
6. [Étape 5 : Monitoring en Production](#étape-5-monitoring-en-production)
7. [Troubleshooting](#troubleshooting)
8. [Commandes Rapides](#commandes-rapides)

---

## Prérequis

### Outils requis

```bash
# Vérifier les dépendances
aws --version          # AWS CLI v2+
terraform --version    # Terraform 1.0+
dig --version         # dnsutils package
curl --version        # HTTP client
jq --version          # JSON processor

# Sur macOS (Homebrew)
brew install awscli terraform dnsutils curl jq

# Sur Ubuntu/Debian
sudo apt-get install awscli terraform dnsutils curl jq

# Sur Amazon Linux/RHEL
sudo yum install awscli terraform bind-utils curl jq
```

### Permissions AWS

Créer une politique IAM pour gérer Route53 :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:*",
        "route53:GetHostedZone",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets",
        "route53:GetChange",
        "route53:GetHealthCheck",
        "route53:GetHealthCheckStatus",
        "route53:ListHealthChecks",
        "route53:CreateHostedZone",
        "route53:DeleteHostedZone"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm"
      ],
      "Resource": "*"
    }
  ]
}
```

### Informations nécessaires

Avant de commencer, préparer :

- [ ] Domaine enregistré chez registrar (ex: GoDaddy)
- [ ] ALB DNS name : `alb-xxxxx.elb.sa-east-2.amazonaws.com`
- [ ] ALB Zone ID pour la région (ex: Z7KQB4TC7K336OM4F)
- [ ] Bastion Elastic IP : `203.0.113.50`
- [ ] VPC ID : `vpc-0123456789abcdef0`
- [ ] Accès AWS CLI configuré : `aws sts get-caller-identity`

---

## Étape 1 : Préparation

### 1.1 Collecter les informations d'infrastructure

```bash
# ALB DNS Name et Zone ID
aws elbv2 describe-load-balancers \
  --region sa-east-2 \
  --query 'LoadBalancers[0].{DNSName:DNSName,ZoneId:CanonicalHostedZoneId}' \
  --output table

# Bastion Elastic IP
aws ec2 describe-addresses \
  --region sa-east-2 \
  --filters "Name=tag:Name,Values=bastion-eip" \
  --query 'Addresses[0].PublicIp' \
  --output text

# VPC ID
aws ec2 describe-vpcs \
  --region sa-east-2 \
  --query 'Vpcs[0].VpcId' \
  --output text
```

### 1.2 Créer un répertoire de travail

```bash
# Créer structure projet
mkdir -p route53-dns
cd route53-dns

# Copier les fichiers de configuration
cp /path/to/route53_complete_config.tf .
cp /path/to/route53_terraform.tfvars.example terraform.tfvars
cp /path/to/dns_validation_scripts.sh .
cp /path/to/dns_advanced_tests.py .

# Initialiser Git
git init
echo "terraform.tfvars" >> .gitignore
echo "*.tfstate*" >> .gitignore
```

### 1.3 Initialiser Terraform

```bash
terraform init

# Vérifier la configuration
terraform fmt -check -recursive
terraform validate
```

---

## Étape 2 : Configuration Terraform

### 2.1 Éditer terraform.tfvars

```bash
cat > terraform.tfvars << 'EOF'
domain_name           = "domaine.com"
aws_region            = "sa-east-2"
environment           = "production"

# Remplacer avec vos valeurs réelles
alb_dns_name          = "alb-xxxxx.elb.sa-east-2.amazonaws.com"
alb_zone_id           = "Z7KQB4TC7K336OM4F"
bastion_elastic_ip    = "203.0.113.50"
internal_service_ip   = "10.0.20.50"
external_partner_ip   = "203.0.113.99"
vpc_id                = "vpc-0123456789abcdef0"

enable_health_checks  = true
EOF

# Vérifier les valeurs
cat terraform.tfvars
```

### 2.2 Planifier le déploiement

```bash
# Générer le plan
terraform plan -out=tfplan

# Vérifier les ressources à créer
terraform show tfplan

# Vérifier les outputs
terraform plan | grep "outputs"
```

### 2.3 Appliquer la configuration

```bash
# Appliquer le plan
terraform apply tfplan

# Vérifier les outputs
terraform output nameservers
terraform output hosted_zone_id
terraform output dns_configuration
```

### 2.4 Sauvegarder les informations importantes

```bash
# Exporter les informations critiques
terraform output -json > deployment_info.json

# Créer un backup
cp terraform.tfstate terraform.tfstate.backup

# Afficher les nameservers
echo "Nameservers (copier vers le registrar):"
terraform output nameservers
```

---

## Étape 3 : Configuration du Registrar

### 3.1 Accéder au registrar (GoDaddy)

```bash
# 1. Connecter à https://www.godaddy.com/
# 2. Aller à "My Products" → "Domains"
# 3. Sélectionner "domaine.com"
# 4. Cliquer sur "Manage DNS"
```

### 3.2 Mettre à jour les nameservers

```
Copier les nameservers Route53 vers GoDaddy :

Nameserver 1: ns-123.awsdns-45.com
Nameserver 2: ns-456.awsdns-78.us
Nameserver 3: ns-789.awsdns-12.co.uk
Nameserver 4: ns-012.awsdns-34.com
```

**Importance:** Les 4 nameservers doivent pointer vers Route53.

### 3.3 Vérifier la propagation

```bash
# Attendre 5-10 minutes, puis tester
dig ns domaine.com

# Output attendu:
# domaine.com.    172800  IN  NS  ns-123.awsdns-45.com.
# domaine.com.    172800  IN  NS  ns-456.awsdns-78.us.
# ...
```

### 3.4 Propagation globale (24-48h)

```bash
# Vérifier propagation en temps réel
https://www.whatsmydns.net/

# Ou via script
#!/bin/bash
for ns in 8.8.8.8 1.1.1.1 9.9.9.9 208.67.222.222; do
  echo "Resolver: $ns"
  dig @$ns api.domaine.com +short
done
```

---

## Étape 4 : Tests et Validation

### 4.1 Tests basiques

```bash
# Vérifier que les records existent dans Route53
aws route53 list-resource-record-sets \
  --hosted-zone-id $(terraform output -raw hosted_zone_id) \
  --query 'ResourceRecordSets[*].[Name,Type,TTL]' \
  --output table

# Résolution API record
dig api.domaine.com

# Résolution Admin record
dig admin.domaine.com

# Résolution External Partner
dig aden.domaine.com
```

### 4.2 Exécuter la suite de validation (Bash)

```bash
# Rendre le script exécutable
chmod +x dns_validation_scripts.sh

# Exécuter les tests
./dns_validation_scripts.sh domaine.com production

# Output attendu:
# ✓ PASS: AWS CLI is installed
# ✓ PASS: AWS credentials valid
# ✓ PASS: Found hosted zone: Z1234567890ABC
# ✓ PASS: Record found: api.domaine.com (A, TTL: 300)
# ✓ PASS: Record found: admin.domaine.com (A, TTL: 3600)
```

### 4.3 Tests avancés (Python)

```bash
# Installer les dépendances
pip install boto3 requests

# Rendre le script exécutable
chmod +x dns_advanced_tests.py

# Exécuter les tests
python3 dns_advanced_tests.py \
  --domain domaine.com \
  --environment production \
  --report text

# Générer un rapport JSON
python3 dns_advanced_tests.py \
  --domain domaine.com \
  --report json \
  --output report.json
```

### 4.4 Tests de connectivité

```bash
# Tester HTTP
curl -v https://api.domaine.com/health

# Tester HTTPS
openssl s_client -connect api.domaine.com:443 -servername api.domaine.com

# Tester SSH (Bastion)
ssh -v admin@admin.domaine.com "whoami"

# Tester résolution interne (depuis EC2)
ssh ec2-user@<instance-ip>
nslookup internal.domaine.com
```

### 4.5 Vérifier les health checks

```bash
# Lister les health checks
aws route53 list-health-checks \
  --query 'HealthChecks[*].[Id,HealthCheckConfig.Type]' \
  --output table

# Vérifier le statut
aws route53 get-health-check-status \
  --health-check-id <health-check-id> \
  --query 'HealthCheckObservations[].StatusReport.Status' \
  --output text
```

---

## Étape 5 : Monitoring en Production

### 5.1 Configurer CloudWatch Monitoring

```bash
# Les health checks sont créés par Terraform
# Vérifier les alarms CloudWatch

aws cloudwatch describe-alarms \
  --alarm-name-prefix "route53" \
  --query 'MetricAlarms[*].[AlarmName,StateValue]' \
  --output table
```

### 5.2 Configuration du monitoring continu

```bash
# Lancer le monitoring continu
python3 dns_advanced_tests.py \
  --domain domaine.com \
  --monitor \
  --interval 300  # 5 minutes

# Sauvegarder dans un fichier de log
python3 dns_advanced_tests.py \
  --domain domaine.com \
  --monitor \
  --interval 300 \
  --output monitoring.log &
```

### 5.3 Créer un cron job pour tests réguliers

```bash
# Ajouter à crontab
crontab -e

# Ajouter cette ligne (test chaque heure)
0 * * * * /home/user/route53-dns/dns_validation_scripts.sh domaine.com production >> /var/log/dns_validation.log 2>&1

# Ou avec Python (tous les 15 minutes)
*/15 * * * * python3 /home/user/route53-dns/dns_advanced_tests.py --domain domaine.com --report json --output /var/log/dns_report.json
```

### 5.4 Configurer les alertes

```bash
# Créer SNS topic pour alertes
aws sns create-topic --name route53-alerts

# Souscrire aux alertes
aws sns subscribe \
  --topic-arn arn:aws:sns:sa-east-2:ACCOUNT_ID:route53-alerts \
  --protocol email \
  --notification-endpoint admin@domaine.com
```

---

## Troubleshooting

### Problème: Nameservers ne se mettent pas à jour

**Symptôme:** `dig ns domaine.com` retourne toujours les anciens NS

**Solution:**

```bash
# 1. Vérifier les NS dans Route53
aws route53 get-hosted-zone \
  --id $(terraform output -raw hosted_zone_id) \
  --query 'DelegationSet.NameServers' \
  --output table

# 2. Vérifier dans GoDaddy (attendre 5-10 min)
# 3. Vider cache DNS local
# macOS
sudo dscacheutil -flushcache

# Linux
sudo systemctl restart systemd-resolved

# 4. Tester avec resolver différent
dig @8.8.8.8 ns domaine.com
dig @1.1.1.1 ns domaine.com

# 5. Si toujours pas de changement après 24h, contacter support
```

### Problème: Records ne résolvent pas

**Symptôme:** `dig api.domaine.com` retourne NXDOMAIN

**Solution:**

```bash
# 1. Vérifier que les records existent
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --query 'ResourceRecordSets[?Name==`api.domaine.com.`]'

# 2. Tester directement avec Route53 nameserver
dig @ns-123.awsdns-45.com api.domaine.com

# 3. Si pas de réponse, vérifier:
#    - Enregistrement créé correctement (vérifier nom exact)
#    - Point final du nom (zone.com vs zone.com.)
#    - ALB/Target exist toujours

# 4. Forcer Terraform refresh
terraform refresh

# 5. Si encore bloqué, recréer le record
terraform taint aws_route53_record.api_weighted
terraform apply
```

### Problème: Health check échoue

**Symptôme:** Health check status = UNHEALTHY

**Solution:**

```bash
# 1. Vérifier l'endpoint
curl -v https://api.domaine.com/health

# 2. Vérifier security group de l'ALB
aws ec2 describe-security-groups \
  --group-ids <ALB-SG-ID> \
  --query 'SecurityGroups[0].IpPermissions' \
  --output table

# 3. Vérifier path /health existe
# Accéder à l'ALB directement:
curl https://alb-xxxxx.elb.sa-east-2.amazonaws.com/health

# 4. Si path inexiste, ajouter à l'application:
# Go:
// router.GET("/health", func(c *gin.Context) {
//   c.JSON(200, gin.H{"status": "ok"})
// })

# Python:
# @app.route('/health')
# def health():
#   return {'status': 'ok'}, 200

# 5. Attendre 30-60s que health check réteste
aws route53 get-health-check-status \
  --health-check-id <HC-ID> \
  --query 'HealthCheckObservations[].StatusReport.Status'
```

### Problème: TTL trop haut (changement lent)

**Symptôme:** Les changements DNS prennent 3600+ secondes

**Solution:**

```bash
# Vérifier TTL actuel
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --query 'ResourceRecordSets[?Name==`api.domaine.com.`].[TTL]'

# Réduire TTL temporairement pour maintenance
terraform apply -var-file="terraform.tfvars" \
  -target="aws_route53_record.api_weighted"

# Éditer terraform.tfvars:
# ttl = 60  # Pendant migration
# Puis après migration:
# ttl = 300

# Ou via AWS CLI (urgence):
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://update-ttl.json
```

---

## Commandes Rapides

### Lister et vérifier

```bash
# Afficher la zone
aws route53 get-hosted-zone --id Z1234567890ABC

# Lister tous les records
aws route53 list-resource-record-sets --hosted-zone-id Z1234567890ABC

# Lister health checks
aws route53 list-health-checks

# Vérifier alarms
aws cloudwatch describe-alarms --alarm-name-prefix route53
```

### Tester résolution

```bash
# Résolution locale
dig api.domaine.com

# Via resolver spécifique
dig @8.8.8.8 api.domaine.com
dig @ns-123.awsdns-45.com api.domaine.com

# Trace complet
dig +trace api.domaine.com

# Zone transfer (test sécurité)
dig @ns-123.awsdns-45.com domaine.com AXFR
```

### Gérer les records

```bash
# Importer zone existante
# (si migration depuis autre registrar)
aws route53 list-resource-record-sets --hosted-zone-id Z-OLD > old-zone.json

# Créer changement batch
# Voir: update-ttl.json example ci-dessous

# Exécuter changement
aws route53 change-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --change-batch file://update-ttl.json
```

### Terraform usefull

```bash
# Plan changement
terraform plan -out=tfplan

# Appliquer changement spécifique
terraform apply -target='aws_route53_record.api_weighted'

# Voir état actuel
terraform state show aws_route53_record.api_weighted

# Détruire tout (attention!)
terraform destroy

# Backup état
cp terraform.tfstate terraform.tfstate.backup.$(date +%s)
```

---

## Checklist Déploiement Complet

- [ ] **Prérequis**
  - [ ] AWS CLI configuré
  - [ ] Domaine enregistré
  - [ ] Permissions IAM correctes
  - [ ] ALB/Bastion/VPC existant

- [ ] **Terraform**
  - [ ] terraform.tfvars créé et valeurs correctes
  - [ ] terraform validate réussi
  - [ ] terraform plan généré
  - [ ] terraform apply exécuté

- [ ] **Registrar**
  - [ ] NS records copiés vers GoDaddy
  - [ ] Attendre 5-10 minutes
  - [ ] Vérifier avec `dig ns domaine.com`

- [ ] **Validation**
  - [ ] dns_validation_scripts.sh executé
  - [ ] Tous les tests PASS
  - [ ] Résolution fonctionne
  - [ ] Health checks HEALTHY

- [ ] **Production**
  - [ ] Monitoring activé
  - [ ] Cron jobs configurés
  - [ ] Alertes CloudWatch activées
  - [ ] Documentation mise à jour

---

## Support et Ressources

- AWS Route53 Docs: https://docs.aws.amazon.com/route53/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- DNS Propagation: https://www.whatsmydns.net/
- Health Check Guide: https://docs.aws.amazon.com/route53/latest/developerguide/health-checks-types.html

**Dernière mise à jour:** Août 2026
**Environnement:** AWS Zone Sud-2, Terraform 1.x, Route53
