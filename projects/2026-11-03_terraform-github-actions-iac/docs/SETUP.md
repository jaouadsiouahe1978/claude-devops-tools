# Setup Guide - Terraform + GitHub Actions IaC Pipeline

## Étapes de Configuration

### 1. Prérequis Locaux

Installez les outils requis:

```bash
# Terraform (macOS avec Homebrew)
brew install terraform

# AWS CLI
brew install awscli

# Vérifier les installations
terraform version
aws --version
```

### 2. Configuration des Credentials AWS

#### Option A: Fichier de configuration AWS (recommandé pour local)

```bash
mkdir -p ~/.aws
nano ~/.aws/credentials
```

Contenu:
```
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

[dev]
aws_access_key_id = YOUR_DEV_ACCESS_KEY
aws_secret_access_key = YOUR_DEV_SECRET_KEY
```

Puis:
```bash
export AWS_PROFILE=default
```

#### Option B: Variables d'environnement

```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_REGION="us-east-1"
```

### 3. Configuration du Repository GitHub

#### Ajouter les Secrets GitHub

1. Allez sur **Settings → Secrets and variables → Actions**
2. Cliquez sur **New repository secret**
3. Ajoutez ces secrets:
   - `AWS_ACCESS_KEY_ID`: Votre AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Votre AWS secret key

⚠️ **Important**: Utilisez un IAM user avec permissions minimum:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "vpc:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### 4. Initialiser Terraform

#### En local:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Éditer terraform.tfvars avec vos valeurs
nano terraform.tfvars

# Initialiser Terraform
terraform init

# Voir ce qui sera créé
terraform plan

# Créer les ressources (à faire seulement en dev/test)
terraform apply
```

#### Résultat attendu:

```
Apply complete! Resources added: 12, changed: 0, destroyed: 0.

Outputs:

nat_gateway_public_ip = null
private_security_group_id = "sg-0abc1234"
private_subnet_cidr = "10.0.2.0/24"
private_subnet_id = "subnet-0abc1234"
public_security_group_id = "sg-0def5678"
public_subnet_cidr = "10.0.1.0/24"
public_subnet_id = "subnet-0def5678"
s3_bucket_arn = "arn:aws:s3:::terraform-demo-dev-a1b2c3d4"
s3_bucket_name = "terraform-demo-dev-a1b2c3d4"
vpc_cidr = "10.0.0.0/16"
vpc_id = "vpc-0abc1234"
```

### 5. Utiliser la Pipeline GitHub Actions

#### Pour tester avec une Pull Request:

```bash
# Créer une branche
git checkout -b test/add-nat-gateway

# Modifier terraform/variables.tf
nano terraform/variables.tf
# Changer: enable_nat_gateway = false → true

git add terraform/variables.tf
git commit -m "feat: enable NAT Gateway"
git push origin test/add-nat-gateway
```

Allez sur GitHub et créez une PR. La pipeline va:
1. ✅ Valider le format Terraform
2. ✅ Vérifier la syntaxe avec `terraform validate`
3. ✅ Générer un plan avec `terraform plan`
4. ✅ Poster le plan comme commentaire sur la PR

#### Pour appliquer les changements:

1. Reviewez le plan dans les commentaires de la PR
2. Approvez la PR et mergez sur `main`
3. La pipeline automatiquement:
   - Exécute `terraform apply`
   - Poste les outputs dans une comment
   - Sauvegarde l'artifact (state file)

### 6. Optimisation pour la Production

#### 6.1 Configurer le Remote State (S3)

D'abord, créez manuellement le bucket S3 pour le state:

```bash
aws s3api create-bucket \
  --bucket tfstate-$(date +%s) \
  --region us-east-1

# Activer le versioning
aws s3api put-bucket-versioning \
  --bucket tfstate-YOUR-BUCKET \
  --versioning-configuration Status=Enabled

# Activer le chiffrement
aws s3api put-bucket-encryption \
  --bucket tfstate-YOUR-BUCKET \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

Puis, décommenter dans `terraform/main.tf`:
```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "prod/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

Réappliquer:
```bash
terraform init
terraform plan
```

#### 6.2 Ajouter du State Locking (DynamoDB)

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

### 7. Commandes Utiles

```bash
# Voir l'état actuel
terraform state list
terraform state show aws_vpc.main

# Voir les outputs
terraform output

# Détruire tout (attention!)
terraform destroy

# Valider la syntaxe
terraform validate

# Vérifier les changements
terraform plan -out=tfplan
terraform show tfplan

# Appliquer spécifiquement certaines ressources
terraform apply -target=aws_vpc.main
```

### 8. Dépannage

#### Erreur: `Error: error configuring Terraform AWS Provider version`

Solution: Vérifiez vos credentials AWS:
```bash
aws sts get-caller-identity
```

#### Erreur: `InvalidClientTokenId` ou `SignatureDoesNotMatch`

Solution: Vérifiez que vos secrets GitHub sont corrects:
```bash
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

#### Terraform state corrompu

Solution: Utilisez un backup:
```bash
# Voir les backups
ls terraform/*.tfstate*

# Restaurer depuis un backup
cp terraform/terraform.tfstate.backup terraform/terraform.tfstate
```

## Checkpoint de Validation

- [ ] `terraform init` réussit sans erreur
- [ ] `terraform plan` affiche les ressources à créer
- [ ] GitHub Secrets configurés (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- [ ] PR crée un commentaire avec le plan Terraform
- [ ] Merge sur main applique automatiquement les changements
- [ ] Ressources visibles dans la console AWS
- [ ] VPC créée avec les subnets et security groups
- [ ] S3 bucket créé avec encryption et versioning activés

## Ressources Utiles

- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Secrets](https://docs.github.io/en/actions/security-guides/using-secrets-in-github-actions)
- [Terraform State Management](https://www.terraform.io/docs/language/state/index.html)
