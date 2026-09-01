# Terraform AWS VPC Networking

## Description
Ce projet vous montre comment créer une infrastructure réseau AWS complète et sécurisée avec Terraform. Vous apprendrez à configurer une VPC, des subnets (publics et privés), des security groups, une Internet Gateway et des route tables.

## Objectifs
- ✅ Infrastructure as Code avec Terraform
- ✅ Créer et configurer une VPC AWS
- ✅ Gérer les subnets (publiques et privées)
- ✅ Configurer les security groups
- ✅ Mettre en place une Internet Gateway
- ✅ Gérer les route tables
- ✅ Déployer des instances EC2 en test

## Technologies
- **Terraform** : Infrastructure as Code
- **AWS** : VPC, EC2, Security Groups
- **Bash** : Scripts de validation

## Pré-requis
```bash
- Terraform >= 1.0
- AWS CLI configuré avec credentials
- Compte AWS actif
- Connaissance basique d'AWS et Terraform
```

## Architecture
```
VPC (10.0.0.0/16)
├── Public Subnet 1 (10.0.1.0/24) - AZ a
│   ├── Internet Gateway
│   ├── Route table publique
│   └── EC2 (optionnel)
├── Public Subnet 2 (10.0.2.0/24) - AZ b
│   └── Route table publique
├── Private Subnet 1 (10.0.10.0/24) - AZ a
│   └── Route table privée
└── Private Subnet 2 (10.0.11.0/24) - AZ b
    └── Route table privée
```

## Étapes

### 1. Initialiser Terraform
```bash
cd projects/2026-09-01_terraform-aws-vpc-networking
terraform init
```

### 2. Planifier le déploiement
```bash
terraform plan -out=tfplan
```

### 3. Appliquer la configuration
```bash
terraform apply tfplan
```

### 4. Récupérer les outputs
```bash
terraform output
```

### 5. Nettoyer les ressources
```bash
terraform destroy
```

## Structure des fichiers
```
.
├── main.tf              # Configuration principale (VPC, Subnets, IGW)
├── security_groups.tf   # Groupes de sécurité
├── route_tables.tf      # Route tables et associations
├── variables.tf         # Variables d'entrée
├── outputs.tf           # Valeurs de sortie
├── terraform.tfvars     # Valeurs des variables
└── ec2_instances.tf     # Instances EC2 de test (optionnel)
```

## Ce qu'on apprend
- **Infrastructure as Code** : Gérer l'infrastructure comme du code
- **VPC Design** : Architecture réseau scalable et sécurisée
- **Security Groups** : Règles de pare-feu AWS
- **Terraform State** : Gestion de l'état de l'infrastructure
- **Modularité** : Organisation du code Terraform
- **Validation** : Tests et vérification de la configuration

## Points clés
1. **VPC** : Réseau virtuel isolé pour les ressources AWS
2. **Subnets publics** : Accessibles depuis internet (IGW)
3. **Subnets privés** : Isolation pour les données sensibles
4. **Security Groups** : Contrôle d'accès au niveau applicatif
5. **Route Tables** : Définit comment les paquets circulent
6. **Terraform State** : Garde trace de votre infrastructure

## Améliorations possibles
- Ajouter un NAT Gateway pour les subnets privés
- Configurer VPC Flow Logs
- Ajouter des Network ACLs supplémentaires
- Implémenter VPC Peering
- Créer une architecture multi-région
