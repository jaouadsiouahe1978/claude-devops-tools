# 📊 DevOps du Jour - 2026-07-12

## Projet : Terraform AWS Auto-Scaling

**Date:** 2026-07-12  
**Durée estimée:** 1 journée  
**Niveau:** Intermédiaire  

---

## 🎯 Objectif du projet

Déployer une **infrastructure AWS complète** avec auto-scaling automatique pour une application web. Ce projet couvre les concepts essentiels de l'Infrastructure as Code (IaC) avec Terraform.

### Concepts clés couverts:
- ✅ Terraform configuration modulaire (vpc.tf, asg.tf, alb.tf, etc.)
- ✅ AWS VPC avec subnets publiques en multi-AZ
- ✅ Application Load Balancer (ALB) avec health checks
- ✅ Auto Scaling Groups (2-5 instances)
- ✅ Security Groups (ingress/egress)
- ✅ Launch Templates avec user_data script
- ✅ Terraform state & outputs
- ✅ Infrastructure reproducible

---

## 🛠️ Technos utilisées

| Technologie | Rôle |
|------------|------|
| **Terraform** | Infrastructure as Code (IaC) |
| **AWS** | Cloud Provider (EC2, VPC, ALB, ASG, SG) |
| **Docker** | Containerisation de l'app |
| **Node.js** | Simple API REST |
| **Bash** | User data script |

---

## 📁 Structure du projet

```
projects/2026-07-12_terraform-aws-autoscaling/
├── main.tf                  # Config Terraform + Provider AWS
├── variables.tf             # Paramètres d'entrée
├── terraform.tfvars         # Valeurs des variables
├── outputs.tf               # Résultats à afficher
│
├── vpc.tf                   # VPC + Subnets + IGW
├── security_groups.tf       # Security Groups (ALB + EC2)
├── alb.tf                   # Application Load Balancer
├── asg.tf                   # Auto Scaling Group + Launch Template
│
├── user_data.sh             # Script de démarrage des instances
├── .gitignore               # Fichiers à ignorer
│
├── README.md                # Documentation complète
├── QUICKSTART.md            # Guide de démarrage rapide
└── PROJECT_SUMMARY.md       # (Cette file)
```

---

## 🚀 Étapes de réalisation

### 1. Prérequis
```bash
# Installer Terraform
brew install terraform      # macOS
sudo apt-get install terraform  # Linux

# Configurer AWS
aws configure
# Entrer: Access Key ID, Secret Access Key, Region, Output Format

# Vérifier
terraform --version
aws sts get-caller-identity
```

### 2. Initialiser le projet
```bash
cd projects/2026-07-12_terraform-aws-autoscaling
terraform init
```

### 3. Planifier
```bash
terraform plan -out=tfplan
# ✅ Voir ce qui va être créé
```

### 4. Déployer
```bash
terraform apply tfplan
# ⏳ Attendre 2-3 minutes...
```

### 5. Tester l'application
```bash
# Récupérer l'URL du Load Balancer
ALB_URL=$(terraform output -raw alb_dns_name)

# Attendre ~2 min que les instances se lancent
sleep 120

# Test health check
curl http://$ALB_URL/health

# Test API
curl http://$ALB_URL/api/hello
```

### 6. Vérifier l'ASG
```bash
# Voir les instances
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# Voir l'ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names demo-asg
```

### 7. Nettoyer
```bash
terraform destroy
# ⚠️ IMPORTANT: Toujours détruire pour éviter les frais!
```

---

## 🏗️ Architecture déployée

```
┌─────────────────────────────────────────────┐
│        Internet (0.0.0.0/0)                 │
└──────────────────┬──────────────────────────┘
                   │ HTTP :80
                   ▼
┌─────────────────────────────────────────────┐
│      AWS Region: eu-west-1                  │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │  Application Load Balancer            │  │
│  │  - Listener: 80 → Target Group:8080   │  │
│  │  - Health Check: /health (30s)        │  │
│  └──────────────┬──────────────────────┘  │
│                 │                         │
│  ┌──────────────┴──────────────┐         │
│  │   Auto Scaling Group        │         │
│  │   (Min: 2, Max: 5)          │         │
│  ├─────────────────────────────┤         │
│  │ Instance 1 (t2.micro)       │         │
│  │ - AZ: eu-west-1a           │         │
│  │ - Docker: Node.js API       │         │
│  │ - Port: 8080                │         │
│  ├─────────────────────────────┤         │
│  │ Instance 2 (t2.micro)       │         │
│  │ - AZ: eu-west-1b           │         │
│  │ - Docker: Node.js API       │         │
│  │ - Port: 8080                │         │
│  └─────────────────────────────┘         │
│                                             │
│  VPC: 10.0.0.0/16                         │
│  - Subnet-1: 10.0.1.0/24 (AZ1)            │
│  - Subnet-2: 10.0.2.0/24 (AZ2)            │
│  - IGW: Internet Gateway                  │
└─────────────────────────────────────────────┘
```

---

## 📚 Ce qu'on apprend

### 🔵 Terraform & IaC
- [ ] Syntaxe HCL (main.tf, variables.tf, outputs.tf)
- [ ] Terraform state (`terraform.tfstate`)
- [ ] Plan & Apply workflow
- [ ] Variables et tfvars
- [ ] Outputs pour accéder aux ressources
- [ ] Data sources (aws_ami, aws_availability_zones)
- [ ] Resource dependencies & lifecycle

### 🔵 AWS VPC & Networking
- [ ] Virtual Private Cloud (VPC)
- [ ] Subnets publiques vs privées
- [ ] Internet Gateway (IGW)
- [ ] Route Tables & Routes
- [ ] Multi-AZ deployment (haute disponibilité)
- [ ] CIDR notation (10.0.0.0/16)

### 🔵 AWS Compute
- [ ] EC2 Instances (t2.micro)
- [ ] Launch Templates
- [ ] Auto Scaling Groups (ASG)
- [ ] Min/Max/Desired capacity
- [ ] Health checks & lifecycle

### 🔵 AWS Load Balancing
- [ ] Application Load Balancer (ALB)
- [ ] Target Groups
- [ ] Health check configuration
- [ ] Listener rules
- [ ] Request routing

### 🔵 AWS Security
- [ ] Security Groups (stateful firewalls)
- [ ] Ingress rules (autoriser)
- [ ] Egress rules (rejeter)
- [ ] Security Group chaining

### 🔵 DevOps Best Practices
- [ ] Infrastructure as Code (IaC)
- [ ] Modularity (séparation des concerns)
- [ ] Reproducibility (même code = même infra)
- [ ] Version control (git)
- [ ] Code review process
- [ ] Tagging strategy
- [ ] Cost optimization

---

## 🔧 Customisation

### Changer la région AWS
```hcl
# terraform.tfvars
aws_region = "us-east-1"
```

### Augmenter la capacité
```hcl
# terraform.tfvars
asg_max_size = 10
asg_desired_capacity = 5
```

### Ajouter HTTPS
```hcl
# alb.tf - Ajouter listener 443 + certificat ACM
```

### Utiliser une autre distro
```hcl
# asg.tf - Modifier le filtre AMI
ami_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
```

---

## 💰 Coûts estimés

| Ressource | Coût/h | Notes |
|-----------|--------|-------|
| EC2 t2.micro | $0.0116 × 2-5 | Free tier eligible |
| ALB | $0.022 | Free tier eligible (limited) |
| Data Transfer | $0.09/Go | Généralement minimal |
| **Total estimé** | **$0.35-0.50/jour** | Si laissé 24h |

⚠️ **TOUJOURS détruire après les tests!**

---

## 📊 Ressources et références

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/state)
- [AWS VPC Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)

---

## 🎓 Prochaines étapes

Après ce projet, vous pouvez:

1. **Améliorer la sécurité:**
   - Ajouter un WAF (Web Application Firewall)
   - Configurer HTTPS/TLS
   - Utiliser AWS Secrets Manager

2. **Améliorer le monitoring:**
   - Ajouter CloudWatch alarms
   - Intégrer Prometheus/Grafana
   - Configurer des scaling policies basées sur les métriques

3. **Infrastructure avancée:**
   - Migrer le state vers S3 + DynamoDB
   - Organiser en modules Terraform réutilisables
   - Utiliser Terraform Cloud/Enterprise

4. **Automation:**
   - Intégrer dans une CI/CD pipeline (GitHub Actions, GitLab CI)
   - Ajouter des tests Terraform (terraform test)
   - Automatiser les déploiements

---

**Créé le:** 2026-07-12  
**Repository:** https://github.com/jaouadsiouahe1978/claude-devops-tools  
**Commit:** 35a74eb  
