# Terraform - Infrastructure AWS avec CloudWatch

## 📋 Objectif
Déployer une infrastructure AWS complète (VPC, EC2, RDS) en tant que code avec Terraform, en appliquant les bonnes pratiques IaC (Infrastructure as Code) et intégrer le monitoring CloudWatch.

## 🎯 Ce qu'on apprend
- **Infrastructure as Code (IaC)** : Décrire l'infrastructure en Terraform HCL
- **État Terraform** : Gérer l'état, le stocker, le versionnner
- **Modules Terraform** : Organiser le code en modules réutilisables
- **Variables et Outputs** : Paramétrer et exposer des valeurs
- **AWS Services** : VPC, EC2, RDS, CloudWatch, IAM, Security Groups
- **Monitoring** : Créer des alarms CloudWatch et des dashboards

## 🛠️ Technos utilisées
- **Terraform** : Infrastructure as Code
- **AWS** : VPC, EC2 (t3.micro), RDS MySQL, CloudWatch
- **AWS CLI** : Validation et déploiement
- **Bash** : Scripts d'aide

## 📚 Pré-requis
- Terraform >= 1.0
- AWS CLI configuré avec des credentials (Access Key + Secret Key)
- Compte AWS avec permissions pour EC2, RDS, VPC, IAM, CloudWatch
- 30-45 minutes

## 🚀 Étapes de réalisation

### 1. Initialiser le projet Terraform
```bash
cd projects/2026-07-20_terraform-aws-infrastructure/terraform
terraform init
```

### 2. Valider la configuration
```bash
terraform validate
terraform plan
```

### 3. Déployer l'infrastructure
```bash
terraform apply
# Accepter avec 'yes'
```

### 4. Récupérer les outputs
```bash
terraform output -json
# Voir l'URL RDS, l'IP publique de l'EC2, etc.
```

### 5. Vérifier sur la console AWS
- Allez sur EC2 → Instances pour voir la machine lancée
- RDS → Databases pour voir la base MySQL
- CloudWatch → Alarms pour voir les alarmes créées

### 6. Détruire l'infrastructure (coûts)
```bash
terraform destroy
# Accepter avec 'yes'
```

## 📁 Structure du projet
```
terraform/
├── main.tf              # Configuration principale
├── variables.tf         # Variables d'entrée
├── outputs.tf           # Outputs (résultats)
├── provider.tf          # Provider AWS
├── terraform.tfvars     # Valeurs des variables (À REMPLIR)
├── modules/
│   ├── vpc/            # Module pour VPC + Security Groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/            # Module pour EC2 + monitoring
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── user_data.sh
│   │   └── outputs.tf
│   └── rds/            # Module pour RDS MySQL
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── scripts/
    └── deploy.sh       # Script de déploiement
```

## 🔧 Configuration nécessaire

### 1. Créer un fichier `terraform.tfvars`
```hcl
aws_region              = "eu-west-1"  # Changer selon votre région
environment             = "dev"
app_name                = "my-app"
instance_type           = "t3.micro"
database_name           = "myapp_db"
database_username       = "admin"
database_password       = "ChangeMe123!"  # À changer !
```

### 2. Configurer les credentials AWS
```bash
aws configure
# Entrer Access Key, Secret Key, région (eu-west-1)
```

## 📊 Ce qu'on déploie

### Réseau (VPC)
- 1 VPC (CIDR : 10.0.0.0/16)
- 2 Subnets (public + private)
- 1 Internet Gateway
- Security Groups pour SSH, HTTP/HTTPS, MySQL

### Calcul (EC2)
- 1 Instance EC2 t3.micro (Amazon Linux 2)
- Installée avec Apache + CloudWatch Agent
- Configure pour collecte de logs et métriques

### Base de données (RDS)
- 1 MySQL 8.0 (db.t3.micro)
- Multi-AZ disabled (dev seulement)
- Backup automatique 7 jours

### Monitoring (CloudWatch)
- 2 Alarms : CPU > 70%, Disk > 80%
- 1 Dashboard avec les métriques
- CloudWatch Logs pour EC2

## ✅ Validation après déploiement

1. **SSH vers l'EC2** :
```bash
EC2_IP=$(terraform output -raw ec2_public_ip)
ssh -i ~/key.pem ec2-user@$EC2_IP
```

2. **Vérifier le serveur Apache** :
```bash
curl http://$EC2_IP
```

3. **Vérifier la base RDS** :
```bash
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
mysql -h $RDS_ENDPOINT -u admin -p$DB_PASS
```

4. **Vérifier CloudWatch** :
- AWS Console → CloudWatch → Alarms
- AWS Console → CloudWatch → Dashboards

## 🧹 Nettoyage
Pour éviter les coûts AWS :
```bash
terraform destroy -auto-approve
```

## 🎓 Aller plus loin
- Ajouter un **Application Load Balancer** (ALB)
- Utiliser **AWS Secrets Manager** pour les mots de passe
- Ajouter **Auto Scaling Group** pour EC2
- Créer des **modules réutilisables** pour VPC/RDS
- Intégrer **Terraform Cloud** pour l'état partagé en équipe

## 📝 Notes
- Les coûts AWS estimés : ~$1-3/jour pour ce lab
- **N'oublie pas de destroyer après l'exercice !**
- Terraform conserve l'état dans `terraform.tfstate` (à ne pas committer)

---
**Durée estimée** : 30-45 minutes
**Difficulté** : Intermédiaire
**Auteur** : Jaouad | Formation DevOps/SRE Grenoble
