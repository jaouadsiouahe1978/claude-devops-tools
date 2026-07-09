# Terraform AWS ELB - Application Load Balancer avec Auto-Scaling

## Description
Ce projet déploie une infrastructure AWS complète utilisant Terraform avec :
- **Application Load Balancer (ALB)** pour distribuer le trafic
- **Auto Scaling Group** pour ajuster automatiquement le nombre d'instances EC2
- **CloudWatch Metrics** pour la collecte de métriques
- **Groupes de sécurité** configurés pour contrôler le trafic
- **VPC, subnets et routage** correctement configurés

Objectif : Apprendre à déployer une infrastructure hautement disponible et scalable sur AWS avec infrastructure-as-code.

## Pré-requis
- AWS CLI configuré avec des credentials valides
- Terraform >= 1.0
- Compte AWS avec permissions EC2, ELB, Auto Scaling, VPC
- Clé SSH AWS pour accéder aux instances

## Technologies utilisées
- **Terraform** : Infrastructure as Code
- **AWS** : EC2, ALB, Auto Scaling, VPC, CloudWatch
- **Bash** : Scripts de déploiement

## Architecture
```
Internet
    ↓
   ALB (Application Load Balancer)
    ↓
VPC + Public Subnets
    ↓
Auto Scaling Group
├── EC2 Instance 1 (nginx)
├── EC2 Instance 2 (nginx)
└── EC2 Instance 3 (nginx) [optionnel]
```

## Étapes de réalisation

### 1. Initialiser Terraform et AWS Provider
- Configurer le provider AWS
- Définir les variables Terraform
- Créer la VPC et subnets

### 2. Créer l'Application Load Balancer (ALB)
- Définir le target group
- Créer les listeners ALB
- Configurer les health checks

### 3. Configurer l'Auto Scaling
- Créer un Launch Template avec user data
- Configurer l'Auto Scaling Group
- Définir les politiques de scaling

### 4. Ajouter CloudWatch
- Métriques d'instances
- Alarmes pour CPU et mémoire
- Logs de déploiement

### 5. Déployer et Tester
- `terraform init`
- `terraform plan`
- `terraform apply`
- Tester l'accès via ALB
- Vérifier auto-scaling en chargeant l'ALB
- `terraform destroy` pour nettoyer

## Ce qu'on apprend
✅ Infrastructure as Code avec Terraform
✅ Configuration d'un ALB pour load balancing
✅ Auto Scaling en fonction de métriques CloudWatch
✅ Sécurité réseau (security groups, VPC)
✅ Variables et outputs Terraform
✅ Gestion de l'état Terraform (state file)
✅ Destruction propre des ressources AWS

## Fichiers du projet
- `main.tf` - Configuration principale VPC, ALB, Auto Scaling
- `variables.tf` - Variables configurables
- `outputs.tf` - Sorties (ALB DNS, etc.)
- `security.tf` - Security groups
- `user_data.sh` - Script d'initialisation des instances
- `terraform.tfvars` - Valeurs des variables
- `deploy.sh` - Script de déploiement
- `destroy.sh` - Script de destruction

## Notes importantes
- Le fichier `terraform.tfstate` ne doit JAMAIS être commité (voir .gitignore)
- Utilisez toujours `terraform plan` avant `apply`
- Pour les environnements de production, utilisez un backend distant (S3)
- Les coûts AWS s'accumulent : ne pas oublier `terraform destroy`
