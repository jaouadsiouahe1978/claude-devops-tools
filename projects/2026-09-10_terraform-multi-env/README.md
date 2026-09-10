# 🏗️ Terraform Multi-Environment Infrastructure

## Objectif
Mettre en place une infrastructure **Infrastructure-as-Code (IaC)** réutilisable et scalable avec Terraform, permettant de gérer plusieurs environnements (dev, staging, prod) avec une seule base de code.

## Technologies
- **Terraform** (>= 1.0)
- **AWS** (VPC, EC2, Security Groups)
- **Docker** (pour local development)
- **Bash** (scripts d'orchestration)

## Architecture
```
terraform/
├── environments/          # Configurations spécifiques par env
│   ├── dev/
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
├── modules/              # Code réutilisable
│   ├── vpc/
│   ├── security/
│   ├── compute/
│   └── monitoring/
├── main.tf               # Configuration principale
├── variables.tf          # Déclaration des variables
├── outputs.tf            # Sorties (outputs)
├── terraform.tfstate     # État (géré localement pour démo)
└── .gitignore
```

## Prérequis
- Terraform installé (`terraform version`)
- Compte AWS (OU simulation en local)
- AWS CLI configuré (optionnel pour démo)
- Bash 4+

## Étapes de réalisation

### 1️⃣ Initialiser le projet Terraform
```bash
cd terraform
terraform init
```

### 2️⃣ Valider la syntaxe
```bash
terraform fmt -recursive        # Formater le code
terraform validate             # Valider la syntaxe
```

### 3️⃣ Planifier l'infrastructure dev
```bash
terraform plan -var-file=environments/dev/terraform.tfvars -out=dev.tfplan
```

### 4️⃣ Appliquer les changements dev
```bash
terraform apply dev.tfplan
```

### 5️⃣ Vérifier les outputs
```bash
terraform output
```

### 6️⃣ Déployer sur un autre environnement (staging)
```bash
terraform plan -var-file=environments/staging/terraform.tfvars -out=staging.tfplan
terraform apply staging.tfplan
```

### 7️⃣ Détruire les ressources (nettoyage)
```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Ce que tu apprends

✅ **Structure Terraform professionnelle** : modules, environnements séparés
✅ **Variables et Outputs** : paramétrage réutilisable
✅ **État Terraform** : gestion de l'état d'infrastructure
✅ **Approche multi-env** : dev/staging/prod avec une même base de code
✅ **Best practices IaC** : DRY, modulaire, versionnable
✅ **Intégration AWS** : VPC, subnets, security groups, EC2
✅ **Automation** : scripts pour déployer rapidement

## Exécution rapide

```bash
# Setup
cd terraform
terraform init

# Dev environment
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# Voir les outputs
terraform output

# Cleanup
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Fichiers créés

| Fichier | Rôle |
|---------|------|
| `main.tf` | Déclaration des ressources AWS |
| `variables.tf` | Variables d'entrée |
| `outputs.tf` | Sorties de l'infrastructure |
| `modules/vpc/` | Module VPC réutilisable |
| `modules/compute/` | Module EC2/instances |
| `environments/*/terraform.tfvars` | Valeurs spécifiques par env |
| `deploy.sh` | Script d'orchestration |

## Points clés
- 🔄 **Réutilisabilité** : modules génériques utilisables dans tous les envs
- 🔐 **Sécurité** : variables sensibles en terraform.tfvars (hors git)
- 📊 **Observabilité** : outputs pour tracker ce qui est créé
- 🚀 **Scalabilité** : ajouter staging/prod = copier terraform.tfvars
- 🧪 **Testabilité** : `terraform plan` sans risque avant `apply`

## Challenge optionnel
- ✨ Ajouter une couche RDS (base de données)
- 🔐 Utiliser AWS Secrets Manager pour les credentials
- 📦 Intégrer Terragrunt pour DRY encore plus poussé
- 🎯 Mettre en place une remote backend (S3 + DynamoDB)
