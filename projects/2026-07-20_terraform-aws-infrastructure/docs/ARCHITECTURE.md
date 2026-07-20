# Architecture - Terraform AWS Infrastructure

## 🏗️ Vue d'ensemble de l'architecture

Cette infrastructure déploie une application web multi-tier sur AWS avec monitoring et logging.

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Region (eu-west-1)               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              VPC (10.0.0.0/16)                        │   │
│  │                                                       │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │   Public Subnet (10.0.1.0/24 - AZ 1)           │ │   │
│  │  │                                                 │ │   │
│  │  │  ┌────────────────────────────────────────────┐ │ │   │
│  │  │  │ EC2 Instance (t3.micro - Amazon Linux 2)   │ │ │   │
│  │  │  │ - Apache Web Server                         │ │ │   │
│  │  │  │ - CloudWatch Agent                          │ │ │   │
│  │  │  │ - Security Group: SSH, HTTP, HTTPS         │ │ │   │
│  │  │  └────────────────────────────────────────────┘ │ │   │
│  │  │                      │                          │ │   │
│  │  │                      │ (TCP 3306)               │ │   │
│  │  └──────────────────────┼──────────────────────────┘ │   │
│  │                         │                             │   │
│  │  ┌─────────────────────────────────────────────────┐ │   │
│  │  │   Private Subnet (10.0.2.0/24 - AZ 2)          │ │   │
│  │  │                                                 │ │   │
│  │  │  ┌────────────────────────────────────────────┐ │ │   │
│  │  │  │ RDS MySQL 8.0 (db.t3.micro)                │ │ │   │
│  │  │  │ - Database: myapp_db                        │ │ │   │
│  │  │  │ - Backup: 7 jours                           │ │ │   │
│  │  │  │ - CloudWatch Logs: error, general          │ │ │   │
│  │  │  │ - Security Group: MySQL only from EC2      │ │ │   │
│  │  │  └────────────────────────────────────────────┘ │ │   │
│  │  └─────────────────────────────────────────────────┘ │   │
│  │                                                       │   │
│  │  Internet Gateway (IGW)                             │   │
│  └─────────────────────────────────────────────────────┘   │
│         │                                                     │
└─────────┼──────────────────────────────────────────────────┘
          │
    ┌─────┴─────┐
    │  Internet  │
    └────────────┘
```

## 🔒 Sécurité

### Security Groups

#### Web Security Group (EC2)
```
Inbound:
  - SSH (22) from 0.0.0.0/0
  - HTTP (80) from 0.0.0.0/0
  - HTTPS (443) from 0.0.0.0/0

Outbound:
  - All traffic allowed (0.0.0.0/0)
```

#### RDS Security Group
```
Inbound:
  - MySQL (3306) from Web SG only

Outbound:
  - All traffic allowed
```

### Network Configuration
- EC2 en subnet public avec accès Internet
- RDS en subnet privé (pas accès Internet)
- Communication interne VPC sur port 3306
- IAM Role pour EC2 → CloudWatch access

## 📊 Monitoring et Logging

### CloudWatch Alarms
1. **EC2 CPU High** : Alerter si CPU > 70% pendant 10 minutes
2. **RDS CPU High** : Alerter si CPU > 75% pendant 10 minutes

### CloudWatch Dashboard
- Métriques EC2 : CPU, Network I/O
- Métriques RDS : CPU, Connections, Storage
- Logs EC2 : Apache access/error, System logs

### CloudWatch Logs
- **EC2 Logs Group** : `/aws/ec2/myapp-dev`
  - Apache access logs
  - Apache error logs
  - System messages

- **RDS Logs** : Automatiquement activés
  - Error logs
  - General logs

## 🗄️ État Terraform

### Stockage de l'état
- **Local** : `terraform.tfstate` (pour dev/test)
- **Production** : Utiliser S3 + DynamoDB pour verrouillage

### Gestion des secrets
- Variables sensibles marquées avec `sensitive = true`
- Mots de passe RDS en `terraform.tfvars` (non versionné)
- Ne pas committer `terraform.tfstate` contenant les secrets

## 📈 Scaling et Performance

### Limitations actuelles
- EC2 : t3.micro (burst capable)
- RDS : t3.micro (shared resources)
- Pas d'Auto Scaling Group
- Pas de Load Balancer

### Pour production
- Utiliser **t3.small** ou supérieur pour EC2
- Utiliser **db.t3.small** minimum pour RDS
- Ajouter **Application Load Balancer** (ALB)
- **Auto Scaling Group** pour EC2
- **RDS Multi-AZ** pour HA
- **RDS Read Replicas** pour read-heavy workloads

## 🚀 Déploiement et Lifecycle

### Initialisation
1. `terraform init` → Télécharge providers et modules
2. `terraform plan` → Affiche les changements
3. `terraform apply` → Crée l'infrastructure

### Mises à jour
```bash
# Modifier variables.tf ou terraform.tfvars
# Puis :
terraform plan
terraform apply
```

### Destruction
```bash
# Pour éviter les coûts AWS :
terraform destroy
```

## 💰 Estimation des coûts (AWS Free Tier)

| Service | Type | Coût/mois |
|---------|------|-----------|
| EC2 | t3.micro (750h/mois) | $0 (Free Tier) |
| RDS | db.t3.micro (750h/mois) | $0 (Free Tier) |
| Data Transfer | 0-1GB | $0 |
| **Total** | | **$0-3** |

⚠️ **Attention** : Au-delà du Free Tier → ~$20-30/mois

## 📝 Bonnes pratiques appliquées

✅ Modules organisés (VPC, EC2, RDS)
✅ Séparation des environnements (variables)
✅ Tagging automatique (default_tags)
✅ CloudWatch monitoring
✅ Security groups restreints
✅ RDS encrypted storage prêt (à activer)
✅ Backup RDS configuré
✅ Logs CloudWatch intégrés
✅ IAM roles au lieu de credentials

## 🔄 Cycle de vie des ressources

```
terraform init
        ↓
terraform validate
        ↓
terraform plan → Review
        ↓
terraform apply
        ↓
Infrastructure opérationnelle
        ↓
terraform destroy (cleanup)
```

## 🛠️ Troubleshooting

### Erreur : "InvalidAMIID"
- L'AMI Amazon Linux 2 n'existe pas dans votre région
- Solution : Changer `aws_region` dans terraform.tfvars

### Erreur : "Insufficient capacity"
- Type d'instance indisponible
- Solution : Essayer `t3.small` à la place de `t3.micro`

### Erreur : "Access Denied"
- Credentials AWS manquants ou permissions insuffisantes
- Solution : `aws configure` et vérifier les permissions IAM

---

**Auteur** : Jaouad | Formation DevOps/SRE Grenoble
**Dernière mise à jour** : 2026-07-20
