# 📋 Commandes Terraform - Guide pratique

## 1. Initialisation et Setup

```bash
# Initialiser le workspace Terraform (télécharge les providers)
terraform init

# Initialiser avec un backend distant (S3)
terraform init -backend-config="bucket=my-state" -backend-config="key=aws/state"

# Supprimer le workspace et réinitialiser
terraform init -upgrade
```

## 2. Validation et Formatage

```bash
# Valider la syntaxe du code HCL
terraform validate

# Formater tous les fichiers .tf
terraform fmt

# Vérifier le formatage sans modifier
terraform fmt -check -recursive

# Vérifier une structure JSON spécifique
terraform validate -json | jq '.diagnostics[] | .detail'
```

## 3. Planning (Avant de déployer)

```bash
# Plan simple (DEV par défaut)
terraform plan

# Plan pour un environnement spécifique
terraform plan -var-file="environments/prod.tfvars"

# Plan pour un module spécifique
terraform plan -target=module.vpc

# Plan pour une ressource spécifique
terraform plan -target=aws_instance.app[0]

# Sauvegarder le plan dans un fichier (pour approval)
terraform plan -var-file="environments/prod.tfvars" -out=tfplan.prod

# Montrer les secrets en plan (⚠️ attention!)
terraform plan -var-file="environments/prod.tfvars" -json | jq '.'

# Plan détaillé avec all attributes
terraform plan -var-file="environments/prod.tfvars" -no-color > plan.txt
```

## 4. Apply (Déployer l'infrastructure)

```bash
# Appliquer les changements (demande confirmation)
terraform apply

# Appliquer depuis un fichier de plan
terraform apply tfplan.prod

# Appliquer sans confirmation (⚠️ dangereux!)
terraform apply -auto-approve

# Appliquer avec variables
terraform apply -var="environment=staging" -var="instance_type=t3.small"

# Appliquer un seul module
terraform apply -target=module.rds -auto-approve

# Appliquer en parallèle (plus rapide)
terraform apply -parallelism=20
```

## 5. État et Debugging

```bash
# Afficher l'état actuel
terraform show

# Lister toutes les ressources dans l'état
terraform state list

# Afficher une ressource spécifique
terraform state show aws_instance.app[0]
terraform state show 'module.vpc.aws_vpc.main'

# Afficher l'état en JSON
terraform show -json | jq '.'

# Exporter le state en JSON pour analyse
terraform state pull > terraform.tfstate.json

# Vérifier le checksum de l'état
terraform state replace-provider -auto-approve hashicorp/aws aws
```

## 6. Outputs

```bash
# Afficher tous les outputs
terraform output

# Afficher un output spécifique
terraform output alb_dns_name

# Afficher les outputs en JSON
terraform output -json

# Afficher les outputs en format human-readable (Terraform 1.1+)
terraform output -raw alb_dns_name
```

## 7. Variables

```bash
# Définir des variables inline
terraform plan -var="aws_region=us-east-1" -var="environment=staging"

# Utiliser un fichier de variables
terraform plan -var-file="custom.tfvars"

# Utiliser plusieurs fichiers (le dernier gagne les conflits)
terraform plan -var-file="common.tfvars" -var-file="prod.tfvars"

# Voir les valeurs des variables
terraform console  # puis taper: var.aws_region
```

## 8. Destroy (Supprimer l'infrastructure)

```bash
# Afficher ce qui sera supprimé
terraform plan -destroy

# Supprimer une ressource spécifique (avec confirmation)
terraform destroy -target=aws_instance.app[0]

# Supprimer tout (demande confirmation)
terraform destroy

# Supprimer tout sans confirmation (⚠️ DANGEREUX!)
terraform destroy -auto-approve
```

## 9. Import (Importer des ressources existantes)

```bash
# D'abord créer la ressource vide dans le code:
# resource "aws_instance" "existing" { }

# Puis importer
terraform import aws_instance.existing i-0123456789abcdef

# Importer avec un indice dans une boucle count
terraform import 'aws_instance.app[0]' i-001111

# Importer dans un module
terraform import 'module.vpc.aws_vpc.main' vpc-12345678
```

## 10. Refresh (Synchroniser l'état local avec AWS)

```bash
# Rafraichir l'état local
terraform refresh

# Rafraichir pour un environnement spécifique
terraform refresh -var-file="environments/prod.tfvars"

# Rafraichir une ressource spécifique
terraform refresh -target=aws_instance.app[0]
```

## 11. Workspaces (Pour gérer plusieurs environnements)

```bash
# Lister les workspaces
terraform workspace list

# Créer un workspace
terraform workspace new prod
terraform workspace new staging

# Switcher vers un workspace
terraform workspace select prod

# Montrer le workspace courant
terraform workspace show

# Supprimer un workspace
terraform workspace delete staging

# Utiliser workspace dans le code:
# count = var.instance_count[terraform.workspace]
```

## 12. Monitoring des changements

```bash
# Voir les changements depuis le dernier apply
terraform plan

# Comparer deux versions du state
terraform state pull > current.json
git show HEAD:terraform.tfstate > previous.json
diff -u previous.json current.json

# Voir l'historique des changements
terraform state list -recursive | sort > resources-after.txt
# Comparer avec un fichier précédent

# Monitoring en continu (tout changement =)
watch -n 60 'terraform plan -json | jq'
```

## 13. Backup et Restore

```bash
# Backup du state
terraform state pull > terraform.tfstate.backup

# Restore depuis un backup
terraform state push terraform.tfstate.backup

# Backup dans S3
aws s3 cp terraform.tfstate s3://my-backups/terraform-$(date +%Y%m%d).tfstate

# Lister les backups
aws s3 ls s3://my-backups/ --recursive
```

## 14. Provisioning multi-environnement

```bash
# Déployer dev, staging, prod automatiquement
for env in dev staging prod; do
  echo "=== Deploying $env ==="
  terraform workspace select $env
  terraform apply -var-file="environments/$env.tfvars" -auto-approve
done

# Ou avec Makefile
make apply ENVIRONMENT=dev
make apply ENVIRONMENT=staging
make apply ENVIRONMENT=prod
```

## 15. Nettoyage et Maintenance

```bash
# Supprimer les fichiers locaux Terraform
rm -rf .terraform .terraform.lock.hcl tfplan*

# Réinitialiser complètement (DANGEREUX!)
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl

# Valider tous les fichiers
find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
  echo "Validating $dir"
  terraform -chdir="$dir" validate
done
```

## 16. Interaction avec AWS CLI

```bash
# Récupérer une ressource Terraform depuis AWS
RESOURCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-app-1" --query 'Reservations[0].Instances[0].InstanceId' -o text)
terraform import aws_instance.app "$RESOURCE_ID"

# Exporter un output pour l'utiliser dans AWS CLI
ALB_DNS=$(terraform output -raw alb_dns_name)
aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-target-groups --load-balancer-arn $ALB_ARN --query 'TargetGroups[0].TargetGroupArn' -o text)

# Tagguer les ressources créées par Terraform
aws ec2 create-tags --resources $(terraform state show -json | jq -r '.values.resources[] | select(.type=="aws_instance") | .address') --tags Key=ManagedByTerraform,Value=true
```

## 17. Diagnostic et Troubleshooting

```bash
# Mode debug verbeux
TF_LOG=DEBUG terraform plan 2>&1 | tee terraform.debug.log

# Log dans un fichier
export TF_LOG_PATH=./terraform.log
TF_LOG=TRACE terraform apply

# Vérifier les providers installés
terraform version

# Vérifier les providers disponibles pour upgrade
terraform init -upgrade

# Voir les changements d'un state pull
terraform state pull | jq '.resources[]'

# Comparer resource par resource
terraform state pull | jq '.resources[] | {type, name, id}' | sort > current.json
```

## 18. Commandes par use-case

### Premier déploiement
```bash
terraform init
terraform validate
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
terraform output
```

### Mise à jour progressive
```bash
terraform plan -target=aws_instance.app
terraform apply -target=aws_instance.app
terraform plan -target=module.rds
terraform apply -target=module.rds
```

### Promotion dev → prod
```bash
terraform workspace select prod
terraform plan -var-file="environments/prod.tfvars"
# Review du plan
terraform apply -var-file="environments/prod.tfvars" -auto-approve
```

### Rollback d'une ressource
```bash
terraform state show aws_instance.app[0] > app.state.json  # Backup
terraform destroy -target=aws_instance.app[0]  # Supprimer
terraform apply -target=aws_instance.app[0]  # Redéployer
```

### Audit et compliance
```bash
terraform show -json | jq '.values.root_module.resources[] | {address: .address, type: .type, values: .values}' > infrastructure-audit.json
```

---

**Pro Tips** 💡
- Toujours faire `terraform plan` avant `apply`
- Utiliser `-var-file` pour chaque environnement
- Commiter `.terraform.lock.hcl` pour reproducibilité
- Utiliser des backends distants (S3) en équipe
- Ajouter `sensitive=true` pour secrets
- Faire des petits déploiements (avec `-target`)
- Automatiser avec CI/CD (GitHub Actions, GitLab CI)
