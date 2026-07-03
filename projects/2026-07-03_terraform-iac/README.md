# 🔧 Terraform AWS - Infrastructure as Code

## 📚 Objectif

Apprendre à utiliser **Terraform** pour créer et gérer une infrastructure AWS complète incluant :
- VPC (Virtual Private Cloud)
- Subnets publics et privés
- Internet Gateway
- Route Tables
- Security Groups
- Instance EC2
- RDS PostgreSQL

**Durée estimée:** 1 journée  
**Niveau:** Débutant à Intermédiaire

---

## 🛠️ Pré-requis

- ✅ AWS Account (free tier possible)
- ✅ Terraform installé (`terraform --version`)
- ✅ AWS CLI configuré (`aws configure`)
- ✅ Clé AWS Access Key ID et Secret Access Key
- ✅ Connaissances basiques de réseau (CIDR, subnets)

---

## 📦 Technologies utilisées

| Technologie | Version | Usage |
|-------------|---------|-------|
| Terraform | >= 1.0 | IaC - Infra provisioning |
| AWS | - | Cloud provider |
| Bash | - | Scripts automation |
| JSON | - | Terraform state |

---

## 🚀 Installation & Setup

### 1. Cloner le projet
```bash
cd projects/2026-07-03_terraform-iac
```

### 2. Configurer AWS Credentials
```bash
# Option A: AWS CLI
aws configure
# Entrez: Access Key, Secret Key, Region (eu-west-1), Format (json)

# Option B: Variables d'environnement
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-1"
```

### 3. Initialiser Terraform
```bash
terraform init
# Télécharge les providers et crée un dossier .terraform
```

### 4. Valider la configuration
```bash
terraform validate
# Vérifiez la syntaxe des fichiers .tf
```

### 5. Planifier le déploiement
```bash
terraform plan -out=tfplan
# Affiche les ressources qui seront créées
# Revisez chaque changement
```

### 6. Appliquer les changements
```bash
terraform apply tfplan
# Déploie réellement l'infrastructure
# Stocke l'état dans terraform.tfstate
```

### 7. Vérifier les ressources
```bash
# Voir les sorties
terraform output

# Vérifier dans AWS Console
# VPC > subnets, Security Groups, EC2, RDS
```

---

## 📋 Structure des fichiers

```
projects/2026-07-03_terraform-iac/
├── main.tf              # Ressources principales (VPC, subnets, gateway)
├── ec2.tf              # Instances EC2
├── rds.tf              # Base de données PostgreSQL
├── security.tf         # Security groups
├── variables.tf        # Variables (customisables)
├── outputs.tf          # Sorties (IPs, DNS, etc.)
├── terraform.tfvars    # Valeurs des variables
├── .gitignore          # Fichiers à ignorer
├── README.md           # Ce fichier
└── scripts/
    ├── deploy.sh       # Script de déploiement automatisé
    └── destroy.sh      # Script pour supprimer l'infra
```

---

## 🎯 Ce qu'on apprend

### Concepts Terraform
- ✅ **Providers**: Configuration AWS (région, authentification)
- ✅ **Resources**: Créer VPC, subnets, EC2, RDS
- ✅ **Variables**: Paramétriser la configuration
- ✅ **Outputs**: Exporter des valeurs (IPs, endpoints)
- ✅ **State**: Gérer l'état de l'infrastructure
- ✅ **Modules**: Réutiliser de la configuration

### Concepts AWS
- ✅ **VPC**: Réseau virtuel privé
- ✅ **Subnets**: Division du VPC en sous-réseaux
- ✅ **Internet Gateway**: Accès internet
- ✅ **Route Tables**: Routage du trafic
- ✅ **Security Groups**: Pare-feu AWS
- ✅ **EC2**: Machines virtuelles
- ✅ **RDS**: Base de données managée

### Bonnes pratiques
- ✅ Infrastructure as Code
- ✅ Versionner la config (git)
- ✅ Séparer dev/prod/staging
- ✅ Utiliser des variables au lieu de hardcoder
- ✅ Revoir le plan avant d'appliquer
- ✅ Documenter avec des outputs

---

## 🔍 Commandes principales

```bash
# Initialisation
terraform init                 # Setup providers
terraform validate             # Vérifie la syntaxe

# Planification
terraform plan                 # Affiche les changements
terraform plan -out=plan.tf    # Sauvegarde le plan

# Déploiement
terraform apply                # Déploie interactif
terraform apply plan.tf        # Applique un plan sauvegardé
terraform apply -auto-approve  # Sans confirmation (⚠️ risky)

# Inspection
terraform state list           # Liste les ressources
terraform state show aws_vpc.main
terraform output               # Affiche les sorties
terraform show                 # Affiche l'état actuel

# Suppression
terraform destroy              # Supprime l'infrastructure
terraform destroy -auto-approve

# Gestion d'état
terraform state mv old_id new_id  # Renommer une ressource
terraform state rm aws_vpc.main    # Supprimer de l'état
terraform state pull              # Télécharger l'état
```

---

## 🔐 Sécurité & Best Practices

### À faire ✅
```hcl
# Utiliser des variables sensibles
variable "db_password" {
  type = string
  sensitive = true
}

# Ignorer terraform.tfstate
echo "terraform.tfstate*" >> .gitignore

# Séparer variables.tf et terraform.tfvars
# terraform.tfvars ne devrait JAMAIS être commité

# Utiliser des workspaces pour dev/prod
terraform workspace new prod
```

### À ne pas faire ❌
```hcl
# ❌ Ne pas hardcoder les secrets
password = "MyPassword123"

# ❌ Ne pas commiter terraform.tfstate
git add terraform.tfstate

# ❌ Ne pas utiliser -auto-approve en production
terraform apply -auto-approve

# ❌ Ne pas supprimer sans vérifier
terraform destroy -auto-approve
```

---

## 📊 Architecture créée

```
┌─────────────────────────────────────────┐
│         AWS Account (eu-west-1)         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   VPC (10.0.0.0/16)             │   │
│  │                                 │   │
│  │  ┌───────────────────────────┐  │   │
│  │  │ Public Subnet (10.0.1.0/24)  │   │
│  │  │ - EC2 Web Server            │   │
│  │  └───────────────────────────┘  │   │
│  │             ↓                    │   │
│  │  ┌───────────────────────────┐  │   │
│  │  │ Private Subnet (10.0.2.0/24) │   │
│  │  │ - RDS PostgreSQL Database    │   │
│  │  └───────────────────────────┘  │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│             ↓                           │
│      [Internet Gateway] ←─ Internet     │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🚨 Troubleshooting

### Erreur: "InvalidUserID.Malformed"
```
Solution: Vérifiez vos AWS credentials
aws sts get-caller-identity
```

### Erreur: "Provider version constraint not met"
```bash
# Mettez à jour les providers
terraform init -upgrade
```

### État corrompu
```bash
# Sauvegarde d'abord
cp terraform.tfstate terraform.tfstate.backup

# Puis nettoyez
terraform state pull  # Inspect
rm terraform.tfstate  # Delete
terraform init        # Reinit
```

### Vérifier les logs détaillés
```bash
export TF_LOG=DEBUG
terraform plan
# Génère beaucoup de logs!
```

---

## 🎓 Variations possibles

### 1. Auto-Scaling Group
```hcl
resource "aws_autoscaling_group" "web" {
  min_size         = 2
  max_size         = 5
  desired_capacity = 3
  # Ajoute plusieurs EC2 automatiquement
}
```

### 2. Load Balancer
```hcl
resource "aws_lb" "main" {
  name = "my-load-balancer"
  # Balance le trafic entre les EC2
}
```

### 3. RDS Multi-AZ
```hcl
multi_az = true  # Haute disponibilité
```

### 4. Modules Terraform
```bash
# Réutiliser la config avec terraform-aws-modules
terraform init
# Utiliser des modules publics
```

### 5. Workspaces pour dev/prod
```bash
terraform workspace new prod
terraform workspace select prod
terraform plan  # Plan pour prod uniquement
```

---

## 📚 Ressources utiles

- [Documentation Terraform](https://www.terraform.io/docs)
- [AWS Provider Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform AWS Modules](https://github.com/terraform-aws-modules)
- [HashiCorp Learn: Terraform](https://learn.hashicorp.com/terraform)
- [AWS VPC Docs](https://docs.aws.amazon.com/vpc/)

---

## ✅ Checklist de réussite

- [ ] Terraform installé et vérifié
- [ ] AWS credentials configurés
- [ ] `terraform init` exécuté
- [ ] `terraform validate` sans erreur
- [ ] `terraform plan` affiche les ressources
- [ ] `terraform apply` crée la VPC
- [ ] Vérifier dans AWS Console
- [ ] `terraform output` affiche les IPs
- [ ] EC2 accessible via SSH
- [ ] RDS accessible depuis EC2
- [ ] `terraform destroy` supprime tout
- [ ] État nettoyé (pas de ressources orphelines)

---

**Créé le:** 2026-07-03  
**Durée:** ~1 journée  
**Niveau:** Débutant → Intermédiaire  
**Prochaine étape:** Ajouter Terraform Cloud, modules réutilisables, CI/CD avec Terraform
