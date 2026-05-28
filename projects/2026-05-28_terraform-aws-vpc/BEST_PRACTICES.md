# Bonnes Pratiques Terraform

## 🎯 Principes Fondamentaux

### 1. Infrastructure as Code (IaC)
- **Versionner** votre code Terraform comme du code applicatif
- **Reviewer** les changements d'infrastructure via Git
- **Répliquer** facilement des environnements (dev, staging, prod)

### 2. État Terraform (tfstate)
```hcl
# Mauvais : état local, pas de backup
# terraform.tfstate dans le répertoire (à éviter en équipe)

# Bon : backend S3 avec locking
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

### 3. Sécurité
- **Ne jamais** commiter les credentials AWS, tokens, ou `terraform.tfvars`
- Utiliser AWS IAM Roles au lieu de clés d'accès (quand possible)
- **Chiffrer** l'état Terraform
- Utiliser **S3 bucket encryption** pour le backend
- **Limiter** les permissions IAM au minimum nécessaire

### 4. Organisation des Fichiers
```
project/
├── main.tf              # VPC, subnets, ressources principales
├── variables.tf         # Déclaration des variables
├── outputs.tf           # Outputs exposés
├── security_groups.tf   # Gestion des SGs
├── ec2.tf              # Instances EC2
├── rds.tf              # Base de données (si applicable)
├── terraform.tfvars    # Valeurs (NE PAS COMMITER)
└── environments/        # Configs par environnement
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

## 📋 Bonnes Pratiques Spécifiques

### 1. Variables
```hcl
# ✅ BON : descriptif et cohérent
variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# ❌ MAUVAIS : pas de description
variable "env" {
  type = string
}
```

### 2. Ressources Nommées Correctement
```hcl
# ✅ BON : noms explicites et cohérents
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "${var.environment}-web-server"
  }
}

# ❌ MAUVAIS : noms génériques
resource "aws_instance" "server" {
  # ...
}
```

### 3. Outputs
```hcl
# ✅ BON : outputs descriptifs avec sensible = false pour secrets
output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = false
}

# ❌ MAUVAIS : pas de description
output "endpoint" {
  value = aws_db_instance.main.endpoint
}
```

### 4. Tags
```hcl
# ✅ BON : tags cohérents via default_tags
provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "MyProject"
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# ❌ MAUVAIS : tags oubliés ou inconsistants
```

### 5. Dépendances Explicites
```hcl
# ✅ BON : dépendances claires
resource "aws_instance" "web" {
  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public
  ]
}

# ❌ MAUVAIS : dépendances implicites qui peuvent casser
```

## 🔄 Workflows Recommandés

### Workflow Local
```bash
# 1. Initialiser
terraform init

# 2. Valider
terraform validate

# 3. Voir les changements
terraform plan

# 4. Appliquer
terraform apply

# 5. Vérifier
terraform output

# 6. Nettoyer
terraform destroy
```

### Workflow en Équipe (avec S3 backend)
```bash
# Toujours en premier
git pull

# Créer une branche
git checkout -b feature/new-resource

# Tester localement
terraform plan -var-file=environments/dev.tfvars

# Commiter et pousser
git add .
git commit -m "Add new RDS instance"
git push origin feature/new-resource

# Créer une PR
# (Code review)

# Après merge en main
git pull
terraform apply -var-file=environments/prod.tfvars
```

## 🚨 Pièges Courants

### 1. Oublier l'état
```bash
# ❌ MAUVAIS : état perdu
rm -rf .terraform terraform.tfstate

# ✅ BON : sauvegarder toujours l'état
git checkout terraform.tfstate  # Si commité
s3 cp s3://backup/terraform.tfstate .  # Si en S3
```

### 2. Oublier les dépendances
```hcl
# ❌ MAUVAIS : ordre d'exécution incertain
resource "aws_instance" "web" {
  subnet_id = aws_subnet.main.id
}

# ✅ BON : dépendances explicites ou implicites claires
```

### 3. Trop de ressources dans un fichier
```bash
# ❌ MAUVAIS : tout dans main.tf (700+ lignes)
# ✅ BON : fichiers séparés par domaine
# - main.tf (VPC, subnets)
# - security_groups.tf
# - ec2.tf
# - rds.tf
# - outputs.tf
```

## 🔐 Sécurité Avancée

### 1. Terraform Cloud/Enterprise
```hcl
terraform {
  cloud {
    organization = "my-organization"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

### 2. Chiffrement d'État
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 3. Versioning d'État
```hcl
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

## 📚 Outils Utiles

### Linting
```bash
# tflint - linter Terraform
tflint

# terraform fmt - formateur
terraform fmt -recursive
```

### Documentation
```bash
# terraform-docs - génère la documentation
terraform-docs markdown . > README.md
```

### Testing
```bash
# Terraform test (v1.6+)
terraform test

# Terratest (Go-based)
go test -v
```

## 📖 Ressources Supplémentaires

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Registry](https://registry.terraform.io/)
- [Terraform Cloud Documentation](https://www.terraform.io/cloud-docs)

---

**Dernière mise à jour** : 2026-05-28
