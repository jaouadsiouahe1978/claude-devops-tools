# Quick Start - Terraform AWS Infrastructure

## ⚡ Lancer le projet en 5 minutes

### Prérequis
```bash
✓ Terraform >= 1.0
✓ AWS CLI configuré
✓ Compte AWS actif
```

### 1️⃣ Configuration
```bash
cd projects/2026-07-20_terraform-aws-infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
```

Éditer `terraform.tfvars` :
```hcl
aws_region  = "eu-west-1"  # Votre région AWS
database_password = "ChangeMe123!"  # Changer ce password
```

### 2️⃣ Initialiser
```bash
terraform init
```

### 3️⃣ Vérifier
```bash
terraform validate
terraform plan
```

### 4️⃣ Déployer
```bash
terraform apply
```

Taper `yes` quand demandé.

### 5️⃣ Récupérer les infos
```bash
terraform output
```

Vous aurez :
- **EC2 Public IP** : pour SSH et Web
- **RDS Endpoint** : pour la base de données
- **URLs CloudWatch** : pour les dashboards

## 🌐 Accéder au serveur web

```bash
# Récupérer l'IP
IP=$(terraform output -raw ec2_public_ip)
curl http://$IP
```

Vous devriez voir la page "DevOps Lab" 🎉

## 🗄️ Accéder à la base de données

```bash
# Récupérer l'endpoint
ENDPOINT=$(terraform output -raw rds_endpoint)
mysql -h $ENDPOINT -u admin -p
# Mot de passe : celui dans terraform.tfvars
```

## 📊 Monitoring

```bash
# Voir les alarms CloudWatch
aws cloudwatch describe-alarms

# Voir les métriques EC2
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=$(terraform output -raw ec2_instance_id) \
  --start-time 2026-07-20T00:00:00Z \
  --end-time 2026-07-20T23:59:59Z \
  --period 300 \
  --statistics Average
```

## 🗑️ Nettoyer (IMPORTANT !)

```bash
terraform destroy
# Taper 'yes' pour confirmer
```

⚠️ **Ne pas oublier de destroy** sinon vous aurez des charges AWS !

## 🐛 Troubleshooting

### "Error: InvalidAMIID"
→ L'AMI n'existe pas dans votre région. Changer `aws_region`.

### "Error: Access Denied"
→ Vérifier vos credentials AWS : `aws sts get-caller-identity`

### "Error: Insufficient capacity"
→ Instance type non disponible. Essayer `t3.small`.

## 📚 En savoir plus
Voir [README.md](README.md) et [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

**Temps estimé** : 30-45 minutes
**Coûts** : ~$0-3/mois (Free Tier AWS)
