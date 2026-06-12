# 🚀 Guide Avancé - Terraform AWS Infrastructure

## 1. Gestion de l'État Terraform

### État local vs. État distant

**État local (par défaut)**
```bash
terraform plan  # Lit .tfstate en local
```

**État distant avec S3 + DynamoDB** (recommandé pour équipes)
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "aws-infra/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Initialiser avec backend distant :
```bash
terraform init -backend-config="bucket=my-state" -backend-config="key=aws/state"
```

### Migrer vers un backend S3
```bash
# 1. Créer bucket + DynamoDB
aws s3api create-bucket --bucket my-terraform-state --region eu-west-1
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# 2. Ajouter backend.tf et migrer
terraform init -migrate-state
```

## 2. Variables sensibles et sécurité

### Passer les secrets sans les commiter

**Méthode 1: Variables d'environnement**
```bash
export TF_VAR_db_password="MySecurePassword123!"
terraform plan
```

**Méthode 2: Fichier locals (git-ignored)**
```hcl
# locals.tf (à git-ignorer)
locals {
  db_password = "MySecurePassword123!"
}
```

**Méthode 3: AWS Secrets Manager**
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}
```

**Méthode 4: Variables sans valeur par défaut**
```hcl
variable "db_password" {
  type      = string
  sensitive = true
  # Pas de default -> demande interactive ou TF_VAR_
}
```

## 3. Workspaces pour multi-environnement

### Créer des workspaces
```bash
terraform workspace new staging
terraform workspace new prod
terraform workspace select prod
terraform plan  # Opère sur prod/terraform.tfstate
```

### Utiliser workspace dans le code
```hcl
variable "instance_count" {
  default = {
    dev     = 1
    staging = 2
    prod    = 3
  }
}

resource "aws_instance" "app" {
  count = var.instance_count[terraform.workspace]
  ...
}
```

## 4. Modules Terraform

### Structure modulaire
```
.
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   ├── rds/
│   └── alb/
├── main.tf (appelle les modules)
└── terraform.tfvars
```

### Utiliser les modules
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block   = "10.0.0.0/16"
  environment  = var.environment
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
}
```

### Sourcer depuis un registry
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "my-cluster"
  cluster_version = "1.27"
}
```

## 5. Validations et tests

### Validations de variables
```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Invalid environment."
  }
}
```

### Tests avec Terraform Testing Framework
```bash
# terraform 1.6+
terraform test
```

### Tests avec Terratest (Go)
```bash
go test -v ./tests/
```

## 6. Gestion des dépendances

### Dépendances implicites
```hcl
resource "aws_instance" "app" {
  subnet_id = aws_subnet.private.id  # Dépend implicitement du subnet
}
```

### Dépendances explicites
```hcl
resource "aws_instance" "app" {
  # ...
  depends_on = [aws_nat_gateway.main]  # Force l'ordre de création
}
```

### Exclure des ressources du plan
```bash
terraform plan -target=aws_instance.app  # Planifier seulement EC2
terraform apply -target=aws_security_group.alb  # Appliquer que le SG
```

## 7. Import de ressources existantes

### Importer une ressource AWS existante
```bash
# D'abord, créer la ressource vide dans le code
# resource "aws_instance" "imported" { }

# Puis importer
terraform import aws_instance.imported i-0123456789abcdef

# Terraform va mettre à jour .tfstate
```

### Importer plusieurs ressources
```bash
terraform import aws_security_group.existing sg-12345678
terraform import aws_subnet.existing subnet-12345678
```

## 8. Optimiser les performances

### Paralléliser les déploiements
```bash
terraform apply -parallelism=10  # Par défaut c'est 10
```

### Utiliser target pour déployer partiellement
```bash
terraform apply -target=module.rds  # Déployer que RDS
```

### Ignorer les changements
```hcl
resource "aws_instance" "app" {
  # ...
  lifecycle {
    ignore_changes = [tags["LastModified"]]
  }
}
```

## 9. Monitoring et audit

### Afficher les changements détaillés
```bash
terraform plan -json | jq '.'
terraform apply -json
```

### Exporter la configuration en JSON
```bash
terraform show -json > state.json
```

### Comparer deux états
```bash
terraform state mv aws_instance.old aws_instance.new
terraform state rm aws_instance.unwanted
terraform state show aws_instance.app
```

## 10. Cost Analysis (terraform cloud)

```bash
# Avec Terraform Cloud
terraform plan  # Affiche les coûts estimés
```

## 11. Disaster Recovery

### Backup d'état
```bash
cp terraform.tfstate terraform.tfstate.backup
aws s3 cp terraform.tfstate.backup s3://my-backups/
```

### Restaurer depuis un backup
```bash
cp terraform.tfstate.backup terraform.tfstate
terraform plan  # Vérifier avant d'appliquer
terraform apply
```

### Récupérer un état de la state history (S3)
```bash
# S3 versioning doit être activé
aws s3api get-object \
  --bucket my-terraform-state \
  --key aws-infra/terraform.tfstate \
  --version-id abc123 \
  terraform.tfstate.old
```

## 12. CI/CD avec Terraform

### GitHub Actions
```yaml
name: Terraform
on: [push, pull_request]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform init
      - run: terraform plan
      - run: terraform apply  # Sur main seulement
        if: github.ref == 'refs/heads/main'
```

### GitLab CI
```yaml
terraform:plan:
  image: hashicorp/terraform:latest
  script:
    - terraform init
    - terraform plan

terraform:apply:
  script:
    - terraform apply -auto-approve
  only:
    - main
```

## 13. Troubleshooting

### Debug mode
```bash
TF_LOG=DEBUG terraform plan  # très verbeux
TF_LOG=INFO terraform apply
export TF_LOG_PATH=./terraform.log
```

### Forcer une refresh
```bash
terraform refresh
terraform state replace-provider hashicorp/aws aws  # Changer de provider
```

### Rollback d'un state
```bash
terraform state pull > old.tfstate
terraform state push old.tfstate  # Revenir à l'ancien état
```

## 14. Best Practices

✅ **DO**:
- Toujours faire `terraform plan` avant `apply`
- Commiter `terraform.lock.hcl` pour reproducibilité
- Utiliser backends distants pour les équipes
- Séparer dev/staging/prod avec workspaces ou répertoires
- Documenter chaque variable et output
- Utiliser `sensitive = true` pour secrets
- Faire des petits commits réguliers
- Utiliser des modules pour réutilisabilité

❌ **DON'T**:
- Commiter `terraform.tfstate` ou `terraform.tfvars` avec secrets
- Utiliser `--auto-approve` en production
- Modifier l'état manuellement (sauf backup/restore)
- Laisser des ressources créées en dehors de Terraform
- Oublier de `terraform destroy` après tests

---

**Pour en savoir plus**: https://www.terraform.io/docs/
