# Terraform Modules & Remote State Management

## 📋 Description

Ce projet enseigne les **bonnes pratiques Terraform en production** en combinant deux concepts clés :
- **Modules Terraform** : réutilisabilité et architecture modulaire
- **Remote State Management** : centralisation de l'état Terraform avec S3 et DynamoDB

L'objectif est de déployer une infrastructure AWS (VPC + Security Groups) de manière modulaire et sécurisée.

## 🎯 Objectifs

✅ Comprendre la structure des modules Terraform  
✅ Implémenter un backend S3 avec verrouillage DynamoDB  
✅ Créer des modules réutilisables (VPC, Security Groups)  
✅ Gérer les variables et outputs efficacement  
✅ Apprendre les bonnes pratiques d'état à distance  

## 🛠️ Technologies

- **Terraform** >= 1.0
- **AWS** (S3, DynamoDB, VPC, EC2 Security Groups)
- **HCL** (HashiCorp Configuration Language)

## 📦 Prérequis

- Terraform installé (`terraform --version`)
- AWS CLI configuré avec des credentials
- Un compte AWS avec accès EC2, VPC, S3, DynamoDB
- Git configuré

## 🚀 Étapes de réalisation

### 1. Préparation S3 + DynamoDB (État à distance)
```bash
# Créer le bucket S3 et table DynamoDB manuellement
# OU utiliser un script terraform-backend provisioner (voir backend-setup/)

aws s3api create-bucket \
  --bucket terraform-state-${USER}-$(date +%s) \
  --region eu-west-1

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### 2. Initialiser Terraform
```bash
cd projects/2026-10-11_terraform-modules-remotestate
terraform init
```

### 3. Configurer les variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec vos valeurs
```

### 4. Planifier et appliquer
```bash
terraform plan
terraform apply
```

### 5. Valider l'infrastructure
```bash
# Afficher les ressources créées
terraform show
terraform output

# Vérifier sur AWS
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=MyProject"
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=MyProject"
```

## 📁 Structure du projet

```
.
├── main.tf               # Configuration root module (appels aux modules)
├── variables.tf          # Variables root (région, tags, etc.)
├── outputs.tf            # Outputs pour afficher IDs ressources
├── backend.tf            # Configuration du remote state (S3 + DynamoDB)
├── terraform.tfvars.example
├── .gitignore
└── modules/
    ├── vpc/
    │   ├── main.tf       # Création VPC, subnets, route tables
    │   ├── variables.tf   # Variables du module VPC
    │   └── outputs.tf     # Outputs (VPC ID, Subnet IDs)
    └── security_group/
        ├── main.tf       # Création security groups
        ├── variables.tf   # Variables SG
        └── outputs.tf     # Outputs (SG IDs)
```

## 🔑 Concepts clés appris

1. **Module Structure** : comment organiser le code Terraform en modules réutilisables
2. **Backend Remote** : centraliser l'état Terraform en S3 avec verrouillage DynamoDB
3. **Variable Passing** : communiquer entre modules via variables et outputs
4. **Versioning Modules** : source paths pour modules locaux
5. **Tagging Strategy** : appliquer des tags cohérents à toutes les ressources

## ⚠️ Points importants

- **Never commit terraform.tfvars** : contient les valeurs sensibles
- **Always use remote state** : en production, jamais d'état local
- **Lock mechanisms** : DynamoDB prévient les modifications concurrentes
- **Modules should be atomic** : chaque module gère un composant logique
- **Use data sources** : pour référencer des ressources existantes

## 🧪 Vérifications

```bash
# Valider la syntaxe
terraform validate

# Formater correctement
terraform fmt -recursive

# Vérifier le plan avant apply
terraform plan -out=tfplan

# État Terraform
terraform state list
terraform state show 'module.vpc.aws_vpc.main'

# Supprimer tout (cleanup)
terraform destroy
```

## 📚 Ressources supplémentaires

- [Terraform Modules Doc](https://www.terraform.io/language/modules)
- [S3 Backend Configuration](https://www.terraform.io/language/settings/backends/s3)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)

## 📝 Prochaines étapes

- Ajouter RDS module
- Implémenter des remote modules (Terraform Registry)
- Intégrer TerraTest pour les tests d'infrastructure
- Ajouter des politiques d'état tagging avancées
