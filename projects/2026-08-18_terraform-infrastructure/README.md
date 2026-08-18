# Terraform Multi-Tier Application Infrastructure

## 📚 Objectif
Créer une infrastructure multi-tier avec Terraform pour provisionner et gérer des ressources d'infrastructure en tant que code. Ce projet démontre les concepts fondamentaux de Terraform : providers, ressources, variables, outputs, et modules.

## 🛠️ Technologies
- **Terraform** (Infrastructure as Code)
- **Docker** (pour simulation locale)
- **Local Terraform State** (gestion d'état)

## 📋 Structure du Projet

```
2026-08-18_terraform-infrastructure/
├── README.md
├── main.tf                 # Configuration principale
├── variables.tf            # Déclaration des variables
├── outputs.tf              # Outputs de l'infrastructure
├── terraform.tfvars        # Valeurs des variables
├── modules/                # Modules réutilisables
│   ├── network/
│   │   └── main.tf
│   ├── webserver/
│   │   └── main.tf
│   └── database/
│       └── main.tf
└── .terraform.gitignore    # Exclusions Git
```

## 🚀 Étapes de Réalisation

### Étape 1: Initialisation Terraform
```bash
cd projects/2026-08-18_terraform-infrastructure
terraform init
```

### Étape 2: Planification
```bash
terraform plan -out=tfplan
```

### Étape 3: Application
```bash
terraform apply tfplan
```

### Étape 4: Inspection de l'état
```bash
terraform state list
terraform state show aws_instance.webserver  # Exemple
terraform output
```

### Étape 5: Destruction
```bash
terraform destroy
```

## 🎯 Cas d'Usage Couverts

1. **Variables de configuration**: Paramétrage de l'infrastructure
2. **Modules réutilisables**: Abstraction et réutilisation de code
3. **Outputs**: Exposition de valeurs importantes
4. **State Management**: Gestion et suivi de l'état d'infrastructure
5. **Multi-environnements**: Configuration pour dev, staging, prod
6. **Gestion des dépendances**: Ordering et dépendances entre ressources

## 📖 Ce qu'on apprend

✅ **Concepts Terraform:**
- Blocs de configuration (resource, variable, output, module)
- Terraform State et son importance
- Interpolation de variables et fonctions
- Plans et appels Terraform
- Gestion des dépendances implicites et explicites

✅ **Bonnes Pratiques DevOps:**
- Infrastructure as Code (IaC)
- Versioning d'infrastructure
- Réutilisabilité via modules
- Gestion d'environnements multiples
- Validation et testing d'infrastructure

✅ **Workflow DevOps:**
- Cycle plan/apply/destroy
- Collaboration via Git
- Code review d'infrastructure
- Audit trail via Git history

## 🧪 Exercices Complémentaires

1. **Modifier les variables**: Changer les noms, tags, configurations
2. **Ajouter une ressource**: Ajouter un nouveau module (cache, monitoring, etc.)
3. **Créer un nouvel environnement**: Dupliquer pour un environnement staging
4. **Utiliser des workspaces**: `terraform workspace create staging`
5. **Ajouter des validations**: Utiliser `variable.validation` blocks
6. **State locking**: Configurer le backend S3 avec locking (pour équipe)

## 📚 Ressources

- [Documentation Terraform officielle](https://www.terraform.io/docs)
- [Module Registry](https://registry.terraform.io)
- [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)
- [Terraform Learning](https://learn.hashicorp.com/terraform)

---
**Créé le:** 2026-08-18  
**Durée:** 1 journée  
**Niveau:** Débutant à Intermédiaire  
**Prérequis:** Terraform installé (`terraform version` doit retourner une version >= 1.0)
