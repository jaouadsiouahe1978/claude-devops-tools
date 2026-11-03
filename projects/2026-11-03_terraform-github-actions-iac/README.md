# Terraform + GitHub Actions - Infrastructure as Code Pipeline

## Description

Ce projet démontre comment créer une pipeline Infrastructure as Code (IaC) automatisée avec Terraform et GitHub Actions. Vous apprendrez à gérer l'infrastructure cloud de manière déclarative, avec un processus de review et d'approbation automatisé.

**Objectif**: Créer une architecture AWS simple (VPC, subnet, security group, S3) gérée entièrement par Terraform, avec une pipeline GitHub Actions qui valide et applique les changements d'infrastructure.

## Pré-requis

- Compte AWS (avec accès aux clés d'accès)
- Repository GitHub
- Git installé localement
- Terraform installé (v1.0+)
- aws-cli v2

## Technologies Utilisées

- **Terraform**: Infrastructure as Code
- **AWS**: Cloud provider (VPC, S3, EC2 Security Groups)
- **GitHub Actions**: Automatisation CI/CD
- **State Management**: Terraform state avec S3 backend

## Structure du Projet

```
.
├── README.md
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml          # Pipeline GitHub Actions
├── terraform/
│   ├── main.tf                           # Configuration principale
│   ├── variables.tf                      # Variables d'entrée
│   ├── outputs.tf                        # Valeurs de sortie
│   ├── vpc.tf                            # Configuration VPC
│   ├── s3.tf                             # Configuration S3
│   ├── security-groups.tf                # Groupes de sécurité
│   ├── terraform.tfvars                  # Valeurs des variables
│   └── terraform.tfvars.example          # Exemple des variables
└── docs/
    └── SETUP.md                          # Guide de configuration
```

## Étapes de Réalisation

### 1. Initialisation Terraform (Jour 1 - Matin)
- Créer les fichiers de configuration Terraform de base
- Configurer le provider AWS
- Définir les variables (région, CIDR, tags)
- Tester avec `terraform plan`

### 2. Créer les Ressources AWS (Jour 1 - Matin/Midi)
- Créer une VPC avec CIDR block
- Créer une subnet publique et privée
- Configurer les security groups (HTTP, HTTPS, SSH)
- Créer un bucket S3 avec versioning et encryption

### 3. Configurer l'État Terraform (Jour 1 - Midi)
- Créer un bucket S3 pour le state Terraform
- Configurer le state backend distant
- Mettre en place le state locking avec DynamoDB

### 4. Créer la Pipeline GitHub Actions (Jour 1 - Après-midi)
- Créer le workflow `terraform-deploy.yml`
- Implémenter `terraform plan` en PR (afficher les changements)
- Implémenter `terraform apply` au merge (appliquer les changements)
- Ajouter les secrets AWS (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

### 5. Tester et Valider (Jour 1 - Fin)
- Créer une branche de test
- Faire une PR avec un changement Terraform
- Valider le plan affiché dans les commentaires GitHub
- Merger et valider l'application automatique

## Ce Qu'on Apprend

✅ **Infrastructure as Code (IaC)**
- Gestion déclarative vs impérative
- Avantages du versioning d'infrastructure
- State management et remote state

✅ **Terraform Avancé**
- Variables et outputs
- Modules (structure réutilisable)
- Interpolation et dépendances implicites
- Plan et apply dans une pipeline

✅ **GitHub Actions pour DevOps**
- Secrets management pour credentials
- Triggers (PR, push, schedules)
- Conditionnels et approbations
- Commentaires dynamiques sur les PR

✅ **AWS Fundamentals**
- VPC et networking
- Security groups et rules
- S3 storage et versioning
- IAM roles et permissions

✅ **GitOps Workflow**
- Git comme source de vérité
- Pull request driven deployments
- Audit trail des changements infra
- Rollback facile via git revert

## Points Clés à Comprendre

### State Management
```bash
# Local state (développement seulement)
terraform init

# Remote state (production)
terraform init -backend-config="bucket=tfstate" -backend-config="key=prod.tfstate" -backend-config="region=us-east-1"
```

### Plan vs Apply
- `terraform plan`: Dry-run, affiche les changements sans les appliquer
- `terraform apply`: Applique les changements réels

### Sensibilités dans les Secrets
- Jamais committer AWS_ACCESS_KEY_ID ou AWS_SECRET_ACCESS_KEY
- Utiliser GitHub Secrets pour stocker les credentials
- Utiliser des IAM roles avec least privilege access

## Ressources Supplémentaires

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions for Terraform](https://github.com/hashicorp/setup-terraform)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

## Checkpoint de Validation

- [ ] Repository initialisé avec structure Terraform
- [ ] `terraform plan` s'exécute sans erreur
- [ ] Variables AWS configurées via secrets GitHub
- [ ] GitHub Actions workflow créé et testé
- [ ] PR génère un plan Terraform dans les commentaires
- [ ] Merge applique automatiquement les changements
- [ ] Ressources AWS visibles dans la console AWS

## Variantes et Améliorations Futures

1. **Multi-environnements**: Créer des workspaces (dev, staging, prod)
2. **Modules Terraform**: Créer des modules réutilisables (VPC, ECS cluster)
3. **Policy as Code**: Ajouter Terraform Cloud/Enterprise pour les approvals
4. **Cost Estimation**: Utiliser `infracost` pour estimer les coûts AWS
5. **Compliance**: Ajouter `tfsec` pour l'analyse de sécurité

## Durée Estimée

**1 jour complet** (8 heures)
- Setup et configuration: 2h
- Développement Terraform: 3h
- Pipeline GitHub Actions: 2h
- Tests et validation: 1h
