# 🚀 Quick Start Guide

## 1. Prérequis

```bash
# Installer Terraform
brew install terraform  # macOS
# ou
sudo apt-get install terraform  # Linux

# Configurer AWS credentials
aws configure
# Entrer: Access Key ID, Secret Access Key, Region, Format

# Vérifier
terraform version
aws sts get-caller-identity
```

## 2. Déployer en 3 commandes

```bash
cd 2026-07-12_terraform-aws-autoscaling

# Initialiser Terraform
terraform init

# Prévisualiser ce qui va être créé
terraform plan

# Déployer! (2-3 minutes)
terraform apply
```

## 3. Tester l'application

```bash
# Récupérer l'URL du Load Balancer
ALB_URL=$(terraform output -raw alb_dns_name)
echo "http://$ALB_URL"

# Attendre ~2 min que les instances se lancent
sleep 120

# Test 1 : Health check
curl http://$ALB_URL/health

# Test 2 : API
curl http://$ALB_URL/api/hello
```

## 4. Voir les instances en action

```bash
# Via AWS CLI
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# Via AWS CLI - ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names demo-asg \
  --query 'AutoScalingGroups[0].[MinSize,DesiredCapacity,MaxSize,Instances[].InstanceId]'
```

## 5. Nettoyer (IMPORTANT! Évite les frais)

```bash
# Supprimer TOUTES les ressources
terraform destroy

# Confirmer avec 'yes'
```

## 📊 Architecture créée

- **VPC** : 10.0.0.0/16
- **2 Subnets** : 10.0.1.0/24 (AZ1) + 10.0.2.0/24 (AZ2)
- **ALB** : Listener sur port 80 → Target Group port 8080
- **ASG** : 2-5 instances t2.micro (Amazon Linux 2)
- **Security Groups** : Autoriser HTTP vers ALB, ALB→EC2, SSH vers EC2

## 🎯 Concepts appris

1. **Terraform State** : `terraform.tfstate` (local, pas en prod!)
2. **Modules** : vpc.tf, asg.tf, alb.tf (séparation des responsabilités)
3. **Outputs** : Récupérer info pour tester (ALB URL, etc.)
4. **Auto Scaling** : 2 policies (scale-up/scale-down) prêtes pour CloudWatch
5. **IAM** : Utilise les credentials AWS du profil configuré
6. **Idempotence** : `terraform apply` peut être relancé sans casser

## 🔍 Debugging

```bash
# Voir tous les outputs
terraform output

# Voir le plan détaillé
terraform plan -json | jq .

# Détruire UNE ressource (attention!)
terraform destroy -target=aws_instance.example

# Voir les logs AWS
aws ec2 get-console-output --instance-id i-xxxxx
```

## 💡 Variations

### Augmenter la capacité
```bash
# Modifier terraform.tfvars
asg_max_size = 10

# Appliquer
terraform apply
```

### Changer de région
```bash
aws_region = "us-east-1"
```

### Ajouter HTTPS
```hcl
# Ajouter listener 443 dans alb.tf + certificat ACM
```

## ⚠️ Coûts

- **Free tier** : t2.micro, ALB (limités)
- **Estimé** : $0.35-0.50/jour si on laisse tourner 24h
- **Toujours détruire après les tests** ⚠️

---

**Besoin d'aide?** Voir README.md pour plus de détails.
