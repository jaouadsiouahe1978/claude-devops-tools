# Terraform AWS Auto-Scaling Infrastructure

## 📋 Objectif
Déployer une infrastructure AWS complète avec auto-scaling d'une application web via **Infrastructure-as-Code avec Terraform**.

## 🛠 Technologies
- **Terraform** : Gestion d'infrastructure
- **AWS** : EC2, ALB, Auto Scaling Groups, VPC, RDS
- **Bash** : Scripts de déploiement et validation
- **CloudWatch** : Monitoring des métriques d'auto-scaling

## 📦 Architecture
```
┌─────────────────────────────────┐
│       AWS VPC                   │
├─────────────────────────────────┤
│  ┌──────────────────────────┐  │
│  │  Application Load        │  │
│  │  Balancer (ALB)          │  │
│  └──────────────────────────┘  │
│           │                     │
│  ┌────────┴────────────────┐   │
│  │  Auto Scaling Group     │   │
│  │  - Min: 2 instances     │   │
│  │  - Max: 6 instances     │   │
│  │  - Target: 70% CPU      │   │
│  └────────┬────────────────┘   │
│           │                     │
│  ┌────────┴────────────────┐   │
│  │  EC2 Instances          │   │
│  │  (web-server-01, etc)   │   │
│  └────────┬────────────────┘   │
│           │                     │
│  ┌────────┴────────────────┐   │
│  │  RDS PostgreSQL         │   │
│  │  (Multi-AZ)             │   │
│  └────────────────────────┘   │
└─────────────────────────────────┘
```

## 🚀 Prérequis
- **AWS Account** avec credentials configurées
- **Terraform >= 1.0**
- **AWS CLI** v2
- **jq** pour parsing JSON

## 📝 Étapes de réalisation

### 1️⃣ Configuration Terraform de base
- Créer provider AWS avec région configurable
- Définir des variables réutilisables
- Configurer backend S3 pour état distant

### 2️⃣ Réseau et sécurité
- Créer VPC avec subnets publics/privés
- Configurer Security Groups pour ALB et instances
- Mettre en place des règles d'ingress/egress

### 3️⃣ Base de données
- Déployer RDS PostgreSQL en Multi-AZ
- Configurer parameter groups et option groups
- Créer subnet group et security group pour RDS

### 4️⃣ Application Load Balancer
- Créer ALB avec health checks
- Configurer target groups
- Mettre en place listener HTTP/HTTPS (certificats auto-signés)

### 5️⃣ Auto Scaling Group
- Créer launch template avec script user-data
- Configurer scaling policies (target tracking)
- Définir métriques CloudWatch pour monitoring

### 6️⃣ Scripts de validation
- Script pour tester connectivité ALB
- Script pour générer charge et observer auto-scaling
- Dashboard CloudWatch via AWS CLI

## 🎓 Concepts apprennants

### Terraform avancé
✅ Modules et réutilisabilité du code  
✅ État distant avec S3 et locking  
✅ Variables, outputs et data sources  
✅ Interpolation et fonctions Terraform  

### AWS Infrastructure
✅ VPC, subnets, routing et NAT  
✅ Security Groups et Network ACLs  
✅ Auto Scaling basé sur métriques  
✅ Load Balancing et health checks  
✅ RDS et haute disponibilité  

### DevOps Practices
✅ Infrastructure-as-Code (IaC)  
✅ Gestion des secrets (variables sensibles)  
✅ Monitoring et alertes CloudWatch  
✅ CI/CD-ready infrastructure  

## ⚙️ Utilisation

### Plan
```bash
cd terraform
terraform init
terraform plan -out=tfplan
```

### Apply
```bash
terraform apply tfplan
```

### Destruction
```bash
terraform destroy
```

### Tester l'auto-scaling
```bash
bash ../scripts/generate-load.sh <ALB_DNS>
```

## 📊 Outputs
- ALB DNS name
- Auto Scaling Group ID
- RDS endpoint
- Security Group IDs

## 🔍 À apprendre
1. Comment Terraform gère les dépendances entre ressources
2. La différence entre `terraform plan` et `apply`
3. L'importance du state file et du locking
4. Comment configurer auto-scaling basé sur métriques réelles
5. Les bonnes pratiques de sécurité avec Terraform (secrets management)
