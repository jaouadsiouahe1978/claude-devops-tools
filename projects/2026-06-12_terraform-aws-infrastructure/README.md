# 🌍 Terraform AWS Infrastructure - Déployer l'IaC sur AWS

**Difficulté :** Débutant/Intermédiaire | **Durée :** 1 journée | **Technos :** Terraform, AWS, HCL

## 🎯 Objectif

Créer une infrastructure AWS complète et reproductible avec Terraform incluant :
- **VPC** avec subnets publics et privés
- **EC2 instances** pour web et base de données
- **RDS** PostgreSQL
- **ALB** pour le load balancing
- **Security Groups** pour la sécurité réseau
- **Variables et outputs** pour la réutilisabilité

## 📋 Pré-requis

- Terraform ≥ 1.0
- Compte AWS avec credentials configurées (`~/.aws/credentials`)
- CLI AWS v2
- Connaissance basique de HCL (Terraform)

## 🚀 Étapes de réalisation

### 1️⃣ Structure et variables
```bash
cd projects/2026-06-12_terraform-aws-infrastructure
terraform init  # Initialiser le working directory
```

### 2️⃣ Validater la configuration
```bash
terraform fmt -check    # Vérifier le formatage
terraform validate      # Valider la syntaxe
```

### 3️⃣ Planifier le déploiement
```bash
terraform plan -out=tfplan
terraform plan -out=tfplan -var-file="environments/dev.tfvars"
```

### 4️⃣ Appliquer la configuration
```bash
terraform apply tfplan
# ⚠️ À faire uniquement si vous avez accès à AWS et les credentials
```

### 5️⃣ Consulter les outputs
```bash
terraform output
terraform output alb_dns_name
```

### 6️⃣ Détruire l'infrastructure (nettoyage)
```bash
terraform destroy -auto-approve
```

## 📚 Ce qu'on apprend

✅ **Infrastructure as Code (IaC)** : Versionner et automatiser son infra AWS  
✅ **Terraform modules** : Structure réutilisable et maintenable  
✅ **VPC networking** : Subnets, routes, security groups  
✅ **Gestion d'état** : fichiers `.tfstate` et best practices  
✅ **Environnements** : Déployer dev, staging, prod avec variables  
✅ **AWS EC2, RDS, ALB** : Services essentiels du cloud  
✅ **Dépendances implicites** : Terraform résout automatiquement l'ordre  

## 📂 Structure du projet

```
.
├── main.tf              # Configuration principale (VPC, EC2, RDS, ALB)
├── variables.tf         # Variables d'entrée
├── outputs.tf           # Outputs à la fin du déploiement
├── provider.tf          # Configuration AWS provider
├── environments/
│   ├── dev.tfvars       # Variables dev
│   ├── staging.tfvars   # Variables staging
│   └── prod.tfvars      # Variables prod (sécurisé)
├── security.tf          # Security Groups
├── networking.tf        # VPC, subnets, routes
└── terraform.tfvars     # Variables par défaut (git ignore secrets)
```

## 💡 Cas d'usage

- **Déployer rapidement une infra AWS** pour un projet
- **Maintenir l'infrastructure en code** et suivre les changements via Git
- **Reproduire un environnement** identique en dev, staging, prod
- **Gérer plusieurs régions AWS** facilement
- **Collaboration en équipe** avec reviews et approvals

## ⚙️ Configuration détaillée

### Ressources créées

| Ressource | Type | Détails |
|-----------|------|---------|
| VPC | `aws_vpc` | CIDR: 10.0.0.0/16 |
| Subnets Publics | `aws_subnet` | 2 AZs, pour ALB/NAT |
| Subnets Privés | `aws_subnet` | 2 AZs, pour EC2 app |
| Internet Gateway | `aws_internet_gateway` | Accès internet public |
| NAT Gateway | `aws_nat_gateway` | Sortie internet pour privé |
| Instances EC2 | `aws_instance` | Web server + 2 réplicas |
| RDS PostgreSQL | `aws_db_instance` | Multi-AZ, automated backups |
| ALB | `aws_lb` | Layer 7 load balancing |
| Target Groups | `aws_lb_target_group` | Routing vers EC2 |

## 🔐 Sécurité

- Variables sensibles dans `.tfvars` (à ajouter en `.gitignore`)
- Security groups restrictifs par défaut
- RDS en subnet privé seulement
- Encryption à la fois données en transit et au repos

## 📝 Notes importantes

1. **État Terraform** : Le fichier `terraform.tfstate` contient l'état actuel. Ne pas commiter !
2. **Backends distants** : Utiliser S3 + DynamoDB pour collab en équipe (voir fichier `backend.tf` commenté)
3. **Variables sensibles** : AWS access keys à passer via `TF_VAR_*` ou `.auto.tfvars`
4. **Coûts AWS** : Attention aux coûts ! Détruire après tests.
5. **Formatage HCL** : `terraform fmt -recursive` pour tout formater

## 🎓 Exercices bonus

- [ ] Ajouter un **CloudFront CDN** devant l'ALB
- [ ] Configurer **Auto Scaling** basé sur CPU/RAM
- [ ] Intégrer **RDS Aurora** au lieu de RDS standard
- [ ] Mettre en place un **backend S3 distant** pour l'état
- [ ] Utiliser des **Terraform modules** pour découpler la config
- [ ] Ajouter **CloudWatch** alarms et monitoring
- [ ] Intégrer avec **GitOps** (Terraform Cloud, HashiCorp Sentinel)

## 📚 Ressources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)
- [AWS VPC Networking](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Terraform Modules Registry](https://registry.terraform.io/browse/modules)

---

**Créé pour Jaouad en formation DevOps/SRE** 🚀
