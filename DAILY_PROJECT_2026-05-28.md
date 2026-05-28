# 📦 Projet DevOps du Jour - 28 Mai 2026

## **Terraform AWS VPC - Infrastructure as Code Complète**

### 🎯 Résumé Rapide
Aujourd'hui, nous créons une infrastructure AWS **complète et réaliste** en utilisant **Terraform** - l'outil DevOps par excellence pour l'Infrastructure as Code. Un projet intermédiaire parfait pour maîtriser IaC, AWS, et les bonnes pratiques.

---

## 📊 Spécifications du Projet

| Aspect | Détail |
|--------|--------|
| **Nom** | Terraform AWS VPC - Infrastructure as Code Complète |
| **Date** | 2026-05-28 |
| **Niveau** | Intermédiaire |
| **Durée** | 1 journée |
| **Technos** | Terraform, AWS (EC2, VPC, SG), Bash |
| **Chemin** | `projects/2026-05-28_terraform-aws-vpc/` |

---

## 🚀 Qu'est-ce qu'on Construit ?

### Infrastructure Déployée:
```
┌─────────────────────────────────────────────┐
│                   AWS VPC                   │
│              (10.0.0.0/16)                  │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    Subnet Public 1                  │   │
│  │    (10.0.1.0/24) - us-east-1a      │   │
│  │  ┌─────────────────────────────┐   │   │
│  │  │ EC2 Instance - Nginx         │   │   │
│  │  │ t2.micro - Ubuntu 20.04      │   │   │
│  │  │ Public IP (Elastic IP)       │   │   │
│  │  └─────────────────────────────┘   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    Subnet Public 2                  │   │
│  │    (10.0.2.0/24) - us-east-1b      │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    Subnet Privé 1                   │   │
│  │    (10.0.10.0/24) - us-east-1a     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │   Internet Gateway                  │   │
│  │   ↓                                 │   │
│  │   Route Tables                      │   │
│  │   Security Groups (HTTP/HTTPS/SSH)  │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## 📁 Structure du Projet

```
projects/2026-05-28_terraform-aws-vpc/
├── README.md                      # Documentation complète
├── BEST_PRACTICES.md              # Bonnes pratiques Terraform
├── 
├── main.tf                        # VPC, subnets, IGW, route tables
├── security_groups.tf             # SG Nginx et instances privées
├── ec2.tf                         # Configuration instances EC2
├── variables.tf                   # Variables réutilisables
├── outputs.tf                     # Outputs pour récupérer les infos
├── terraform.tfvars               # Valeurs des variables
├── user_data.sh                   # Script init Nginx
├── .gitignore                     # Ignorer état + credentials
│
└── scripts/
    ├── init.sh                    # Initialiser Terraform
    ├── plan.sh                    # Voir le plan d'exécution
    ├── apply.sh                   # Appliquer les changements
    ├── destroy.sh                 # Détruire les ressources
    └── outputs.sh                 # Afficher les outputs
```

---

## 🔨 Étapes de Réalisation

### 1️⃣ Initialisation
```bash
cd projects/2026-05-28_terraform-aws-vpc/
./scripts/init.sh
# ou
terraform init
```

### 2️⃣ Validation & Plan
```bash
terraform validate      # Vérifier la syntaxe
terraform plan         # Voir ce qui sera créé
```

### 3️⃣ Déploiement
```bash
./scripts/apply.sh
# ou
terraform apply
```

### 4️⃣ Vérification
```bash
terraform output                    # Afficher tous les outputs
IP=$(terraform output -raw nginx_instance_ip)
curl http://$IP                     # Tester Nginx
```

### 5️⃣ Cleanup
```bash
./scripts/destroy.sh                # Détruire toutes les ressources
```

---

## 💡 Concepts Clés Appris

### 1. **VPC (Virtual Private Cloud)**
- Réseau isolé et contrôlé
- Choisir son propre CIDR block
- Segmentation en subnets

### 2. **Subnets Publics vs Privés**
- **Public**: accessible depuis Internet (via IGW)
- **Privé**: isolé (requiert NAT Gateway pour sortir)

### 3. **Internet Gateway & Route Tables**
- IGW: passerelle vers Internet
- Route Tables: définit où router le trafic (0.0.0.0/0 → IGW)

### 4. **Security Groups**
- Pare-feu virtuel par-instance
- Règles Inbound/Outbound
- Basées sur protocoles, ports, sources IP

### 5. **Terraform State**
- `terraform.tfstate`: représentation de l'infra
- Critique pour la gestion d'infra
- À versionner et sauvegarder

### 6. **Variables & Outputs**
- Variables: entrées flexibles
- Outputs: récupérer les résultats
- Permet réutilisabilité et modularité

---

## 📚 Ce qu'on Apprend

| Thème | Apprentissage |
|-------|--------------|
| **HCL** | Syntaxe Terraform, blocks, ressources |
| **AWS** | VPC, Subnets, SG, EC2, IAM |
| **IaC** | Versioning, reproducibilité, best practices |
| **State** | Importance, backend, locking |
| **CI/CD** | Intégration avec pipelines |

---

## ⚠️ Points Importants

- **AWS Costs**: Ressources générèrent des coûts. Utilisez `terraform destroy` après tests!
- **Credentials**: Ne JAMAIS commiter `.aws/credentials` ou `terraform.tfvars`
- **Région**: Par défaut `us-east-1`. Changez dans `terraform.tfvars` si nécessaire
- **État**: Critiquement important. Ne pas perdre `terraform.tfstate`

---

## 🎓 Exercices Bonus

1. ✅ Ajouter une **RDS (PostgreSQL)** à la VPC
2. ✅ Configurer un **Application Load Balancer**
3. ✅ Migrer l'état vers **S3 backend**
4. ✅ Créer des **modules Terraform** réutilisables
5. ✅ Ajouter l'**auto-scaling** d'instances
6. ✅ Intégrer avec **GitHub Actions** pour CI/CD

---

## 📖 Fichiers Clés à Comprendre

### `main.tf` - Infrastructure de Base
- Déclaration du provider AWS
- Création VPC + subnets + IGW
- Route tables et associations
- Data sources pour AMI et AZs

### `ec2.tf` - Instances
- Instances EC2 t2.micro
- User data pour installer Nginx
- Elastic IPs

### `security_groups.tf` - Sécurité
- Règles HTTP/HTTPS/SSH
- Isolation entre public/privé

### `variables.tf` & `terraform.tfvars`
- Variables paramétrables
- Rendre l'infra flexible

### `outputs.tf` - Résultats
- Afficher IPs, IDs, URLs importantes

---

## 🔗 Ressources Supplémentaires

- [Terraform Official Docs](https://www.terraform.io/docs)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)

---

## ✅ Checklist du Projet

- ✅ VPC et subnets créés
- ✅ Internet Gateway configuré
- ✅ Route Tables et associations faites
- ✅ Security Groups définis
- ✅ EC2 avec Nginx lancée
- ✅ Outputs pour récupérer les infos
- ✅ Scripts d'aide créés
- ✅ Documentation complète
- ✅ Bonnes pratiques documentées
- ✅ Projet commité et pushé

---

## 📞 Besoin d'Aide ?

Problèmes courants:

| Problème | Solution |
|----------|----------|
| "Error acquiring state lock" | `terraform force-unlock <LOCK_ID>` |
| "InvalidAMIID.NotFound" | Vérifier AMI dans la région |
| "UnauthorizedOperation" | Vérifier permissions IAM |
| Nginx inaccessible | Attendre 60 secondes (user-data) |

---

**Créé le 28 mai 2026 par Claude Code pour Jaouad** 🚀
