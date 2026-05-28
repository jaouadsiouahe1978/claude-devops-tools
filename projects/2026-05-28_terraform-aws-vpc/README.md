# Terraform AWS VPC - Infrastructure as Code Complète

## 📋 Description
Ce projet explore **Terraform** pour provisionner une infrastructure AWS complète avec une VPC, subnets, security groups, et un serveur EC2 Nginx. C'est un projet idéal pour apprendre l'IaC (Infrastructure as Code) et la gestion d'état Terraform.

## 🎯 Objectifs
- Créer une VPC AWS avec subnets publics et privés
- Configurer les Security Groups pour contrôler le trafic
- Lancer une instance EC2 avec Nginx automatiquement
- Gérer l'état Terraform (local et S3 backend)
- Utiliser les variables et outputs pour la flexibilité
- Apprendre les bonnes pratiques Terraform

## 🛠️ Technologies
- **Terraform** (Infrastructure as Code)
- **AWS** (EC2, VPC, Security Groups, Route53)
- **Bash** (scripts auxiliaires)
- **Docker** (optionnel pour tester Terraform localement)

## 📦 Pré-requis
- AWS CLI configuré avec des credentials
- Terraform installé (v1.0+)
- Git et Bash
- Éditeur de texte (VS Code, Vim, etc.)

### Configuration AWS
```bash
aws configure
# Entrez vos AWS Access Key ID et Secret Access Key
```

## 🚀 Étapes de Réalisation

### 1. Initialisation du Projet Terraform
```bash
cd projects/2026-05-28_terraform-aws-vpc
terraform init
```

### 2. Vérifier la Configuration
```bash
terraform validate
terraform plan
```

### 3. Déployer l'Infrastructure
```bash
terraform apply
```

### 4. Récupérer les Outputs
```bash
terraform output
# Affiche l'IP publique de l'instance EC2
```

### 5. Tester l'Instance EC2
```bash
# Récupérer l'IP publique
IP=$(terraform output -raw nginx_instance_ip)
curl http://$IP
# Devrait afficher une page Nginx
```

### 6. Nettoyer les Ressources
```bash
terraform destroy
```

## 📚 Structure du Projet

```
2026-05-28_terraform-aws-vpc/
├── README.md                 # Ce fichier
├── main.tf                   # Configuration principale (VPC, subnets)
├── security_groups.tf        # Définition des Security Groups
├── ec2.tf                    # Configuration instance EC2
├── variables.tf              # Variables réutilisables
├── outputs.tf                # Outputs pour récupérer les infos
├── terraform.tfvars          # Valeurs des variables (NE PAS COMMITER)
├── .gitignore                # Ignorer les fichiers sensibles
├── user_data.sh              # Script d'initialisation pour l'instance
└── scripts/
    ├── init.sh               # Initialiser Terraform
    ├── plan.sh               # Voir le plan d'exécution
    ├── apply.sh              # Appliquer les changements
    └── destroy.sh            # Détruire les ressources
```

## 💡 Concepts Clés

### 1. **VPC (Virtual Private Cloud)**
- Réseau isolé dans AWS
- Permet de contrôler la topologie du réseau
- Subnets : subdivisions logiques de la VPC

### 2. **Subnets**
- Subnet PUBLIC : instances accessibles depuis Internet (NAT gateway requis)
- Subnet PRIVÉ : instances non directement accessibles

### 3. **Internet Gateway & Route Table**
- Internet Gateway : permet la connexion Internet
- Route Table : définit où router le trafic

### 4. **Security Groups**
- Pare-feu virtuel pour les instances
- Entrantes (inbound) et sortantes (outbound)
- Basées sur des règles IP/port

### 5. **État Terraform**
- Fichier `terraform.tfstate` : représentation de l'infrastructure actuelle
- Important : backuper et versionner l'état
- Backend S3 pour les équipes (mieux que fichier local)

### 6. **Variables & Outputs**
- Variables : entrées réutilisables
- Outputs : sorties exposées après `apply`
- Permet la flexibilité et la réutilisation

## 🎓 Ce qu'on Apprend

1. **Syntaxe HCL (Terraform)**
   - Blocks, ressources, variables, conditions
   - Interpolation `${var.name}`

2. **Gestion AWS avec IaC**
   - Déclarer des ressources au lieu de cliquer
   - Versioning et tracking des changements
   - Reproducibilité de l'infrastructure

3. **Bonnes Pratiques**
   - Organiser le code en fichiers logiques
   - Utiliser des variables pour la flexibilité
   - Outputs pour exposer les données importantes
   - `.gitignore` pour les secrets et états

4. **Debugging et Troubleshooting**
   - Lire les logs Terraform (`TF_LOG=DEBUG`)
   - Utiliser `terraform state` pour inspecter l'état
   - Validation et planification avant apply

5. **État Terraform**
   - Importance du `.tfstate`
   - Backends locaux vs distants
   - Locking pour les équipes

## 🔍 Exemples d'Utilisation

### Modifier les Variables
Éditer `terraform.tfvars` :
```hcl
aws_region = "eu-west-1"
vpc_cidr   = "10.1.0.0/16"
instance_type = "t2.small"
```

### Ajouter un Output
Dans `outputs.tf` :
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
  description = "ID de la VPC créée"
}
```

### Utiliser les Données AWS Existantes
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
```

## ⚠️ Points d'Attention

1. **AWS Costs** : Les ressources EC2 génèrent des coûts. N'oubliez pas de `terraform destroy`
2. **Credentials** : Ne commitez JAMAIS les credentials AWS
3. **État** : Backupez votre `terraform.tfstate` (contient les IDs des ressources)
4. **Permissions IAM** : Vérifiez que votre utilisateur AWS a les bonnes permissions

## 🚨 Troubleshooting

### Erreur : "Error: Error acquiring the state lock"
État verrouillé. Solution :
```bash
terraform force-unlock <LOCK_ID>
```

### Erreur : "InvalidAMIID.NotFound"
L'AMI spécifiée n'existe pas dans votre région. Vérifiez dans `variables.tf`.

### Erreur : "UnauthorizedOperation"
Permissions IAM insuffisantes. Vérifiez votre utilisateur AWS.

## 📖 Ressources

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 🎯 Exercices Supplémentaires

1. Ajouter une RDS (base de données) à la VPC
2. Configurer un Application Load Balancer
3. Migrer l'état vers un backend S3
4. Ajouter des tags à toutes les ressources
5. Créer des modules Terraform réutilisables

## 📝 Notes

- Ce projet utilise AWS us-east-1 par défaut. Changez la région dans `terraform.tfvars` si nécessaire.
- L'AMI utilisée est Ubuntu 20.04 (ajustable via variables)
- Le script `user_data.sh` installe Nginx automatiquement sur l'instance

---

**Date créée** : 2026-05-28  
**Niveau** : Intermédiaire  
**Durée estimée** : 1 journée
