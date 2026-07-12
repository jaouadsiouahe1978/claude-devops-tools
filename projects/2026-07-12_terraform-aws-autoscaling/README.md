# 🏗️ Terraform AWS Auto-Scaling avec Application Web

## 📋 Objectif

Déployer une infrastructure AWS complète avec **auto-scaling** pour une application web. Ce projet couvre les concepts essentiels :
- Création d'instances EC2
- Load Balancing (ALB)
- Auto Scaling Groups
- Configuration Terraform modulaire
- Variables d'environnement et outputs

## 🛠️ Technos utilisées

- **Terraform** - Infrastructure as Code (IaC)
- **AWS** - EC2, ALB, Auto Scaling Groups, Security Groups, VPC
- **Bash** - Scripts de provisioning
- **Docker** - Containerisation légère de l'app

## 📊 Architecture

```
┌─────────────────────────────────────────┐
│         Internet Gateway / ALB           │
│         (Load Balancer)                  │
└─────────────┬───────────────────────────┘
              │
┌─────────────┴───────────────────────────┐
│      Auto Scaling Group (ASG)            │
├──────────────────────────────────────────┤
│  Instance 1 (t2.micro)  :80/8080         │
│  Instance 2 (t2.micro)  :80/8080         │
│  Instance N (t2.micro)  :80/8080         │
└──────────────────────────────────────────┘
        (Scaling: 2-5 instances)
```

## 📦 Structure du projet

```
2026-07-12_terraform-aws-autoscaling/
├── README.md
├── main.tf                 # Configuration principale
├── variables.tf            # Variables d'entrée
├── outputs.tf              # Outputs (affichage)
├── vpc.tf                  # VPC et Subnets
├── security_groups.tf      # Security Groups
├── asg.tf                  # Auto Scaling Group
├── alb.tf                  # Load Balancer
├── user_data.sh            # Script de démarrage des instances
├── terraform.tfvars        # Valeurs des variables
└── .gitignore              # Fichiers à ignorer
```

## 🚀 Pré-requis

- **AWS Account** avec accès aux clés d'accès (Access Key ID + Secret Access Key)
- **Terraform** >= 1.0 installé
- **AWS CLI** configuré (`aws configure`)
- **Git** pour le versionning

## 📝 Étapes de réalisation

### 1️⃣ Initialiser Terraform
```bash
cd 2026-07-12_terraform-aws-autoscaling
terraform init
```

### 2️⃣ Planifier le déploiement
```bash
terraform plan -out=tfplan
```
**Vérifie** ce qui va être créé : VPC, Security Groups, ASG, ALB, etc.

### 3️⃣ Appliquer la configuration
```bash
terraform apply tfplan
```
**Crée** l'infrastructure sur AWS (2-3 minutes)

### 4️⃣ Tester l'application
```bash
# Récupérer l'URL du Load Balancer
terraform output alb_dns_name

# Tester l'endpoint
curl http://$(terraform output -raw alb_dns_name)/api/health
```

### 5️⃣ Vérifier l'auto-scaling
```bash
# Voir l'ASG en action
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names demo-asg

# Simuler une charge (optionnel)
# Les instances devraient scaler automatiquement
```

### 6️⃣ Nettoyer les ressources
```bash
terraform destroy
```
**Supprime** toutes les ressources AWS créées (évite les frais)

## 🎯 Ce qu'on apprend

✅ **Terraform IaC**
- Syntaxe HCL, variables, outputs, state
- Organisation modulaire (vpc.tf, asg.tf, etc.)

✅ **AWS Networking**
- VPC, Subnets publiques/privées
- Security Groups (ingress/egress rules)
- Internet Gateway

✅ **Compute & Scaling**
- Instances EC2 (t2.micro, user_data)
- Auto Scaling Groups (min/max/desired capacity)
- Launch Templates

✅ **Load Balancing**
- Application Load Balancer (ALB)
- Target Groups
- Health Checks

✅ **DevOps Practices**
- Infrastructure as Code
- Reproducibility & Version Control
- State Management
- Cost Optimization (t2.micro)

## 📚 Fichiers clés

### `variables.tf`
Définit les paramètres : région AWS, instance type, capacité min/max, etc.

### `main.tf`
Configuration de base : provider AWS, variables.

### `vpc.tf`
Crée un VPC avec 2 subnets publiques pour les instances.

### `security_groups.tf`
- Groupe pour ALB : autoriser HTTP/HTTPS (80, 443)
- Groupe pour EC2 : autoriser trafic depuis ALB (8080)

### `asg.tf`
Auto Scaling Group : 
- Min: 2, Max: 5 instances
- Launch Template avec user_data
- Health checks

### `alb.tf`
Application Load Balancer :
- Listener sur port 80
- Target Group (healthcheck /health)
- Routing vers instances

### `user_data.sh`
Script exécuté au démarrage de chaque instance :
- Installe Docker
- Lance un conteneur Node.js simple (API)
- Expose l'app sur port 8080

## 🔧 Customisation

### Changer la région AWS
```bash
# Dans terraform.tfvars
aws_region = "eu-west-1"
```

### Modifier la capacité de scaling
```hcl
# Dans asg.tf
min_size = 2
max_size = 10        # Augmenter selon les besoins
desired_capacity = 3
```

### Utiliser une autre distro Linux
```hcl
# Dans variables.tf
ami_filter = "amzn2-ami-hvm-*"  # AL2
# ou
ami_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"  # Ubuntu
```

## 📈 Métriques & Monitoring

Après le déploiement, voir les métriques dans AWS CloudWatch :
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time 2026-07-12T00:00:00Z \
  --end-time 2026-07-12T23:59:59Z \
  --period 300 \
  --statistics Average
```

## 🚨 Troubleshooting

### Erreur: "Access Denied"
```bash
# Vérifier les clés AWS
aws sts get-caller-identity

# Reconfigurer
aws configure
```

### Instances ne se lancent pas
```bash
# Vérifier les logs du user_data
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'

# Voir les erreurs CloudInit
aws ec2 get-console-output --instance-id <instance-id>
```

### ALB en attente (pending)
Les instances mettent du temps à devenir saines (healthcheck). Attendre 2-3 min.

## 💰 Coût estimé

- **EC2 t2.micro** (eligible free tier) : ~0.0116 USD/h × 2-5 instances
- **ALB** : ~0.022 USD/h
- **Data Transfer** : 0.09 USD/Go (généralement minimal)

**Total** : ~0.35-0.50 USD/jour (si on laisse tourner 24h)

## 🔐 Bonnes pratiques appliquées

✅ Pas de secrets en dur (utiliser AWS Secrets Manager en prod)
✅ État Terraform stocké en local (en prod: S3 + DynamoDB)
✅ Nommage cohérent (tags, prefixes)
✅ Outputs exposés pour faciliter les tests
✅ Security Groups restrictifs
✅ User data idempotent

## 📖 Ressources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/state)
