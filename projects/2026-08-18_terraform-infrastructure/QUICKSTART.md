# Quick Start Guide - Terraform Infrastructure

## 🚀 5-Minute Setup

### 1. Vérifier Terraform
```bash
terraform version
```
✅ Doit retourner une version >= 1.0

### 2. Initialiser le projet
```bash
cd projects/2026-08-18_terraform-infrastructure
terraform init
```
✅ Crée le répertoire `.terraform/` et initialise les modules

### 3. Valider la configuration
```bash
terraform validate
```
✅ Doit afficher "Success! The configuration is valid."

### 4. Voir le plan d'exécution
```bash
terraform plan
```
✅ Affiche les ressources qui seront créées

### 5. Appliquer la configuration
```bash
terraform apply
```
Tape `yes` pour confirmer

✅ Crée les fichiers de configuration dans le répertoire `config/`

### 6. Inspecter les outputs
```bash
terraform output
terraform output -json | jq .
```
✅ Affiche les sorties (URLs, fichiers de config, etc.)

### 7. Vérifier l'état
```bash
terraform state list
cat terraform.tfstate | jq .
```
✅ Montre toutes les ressources gérées par Terraform

### 8. Nettoyer
```bash
terraform destroy
```
Tape `yes` pour confirmer

✅ Supprime toutes les ressources créées

---

## 🎓 Points d'apprentissage clés

| Concept | Exemple | Fichier |
|---------|---------|---------|
| **Provider** | `provider "local"` | main.tf |
| **Resource** | `resource "local_file"` | main.tf |
| **Variables** | `variable "environment"` | variables.tf |
| **Validation** | `validation { condition = ... }` | variables.tf |
| **Module** | `module "webserver"` | main.tf |
| **Output** | `output "infrastructure_summary"` | outputs.tf |
| **Locals** | `locals { common_tags = ... }` | main.tf |
| **Templating** | `templatefile()` | main.tf |
| **State** | `terraform.tfstate` | (généré) |

---

## 🔍 Commandes Utiles

```bash
# Lister les workspaces
terraform workspace list

# Créer un workspace
terraform workspace new staging

# Changer de workspace
terraform workspace select staging

# Formater le code
terraform fmt -recursive .

# Déboguer
TF_LOG=DEBUG terraform plan

# Voir les détails d'une ressource
terraform state show local_file.webserver_config

# Importer une ressource existante
terraform import <type>.<name> <id>

# Forcer la recréation d'une ressource
terraform taint <resource>

# Sauvegarder l'état
terraform state pull > backup.tfstate
```

---

## 📝 Fichiers Générés

Après `terraform apply`, vous verrez:

```
config/
├── webserver-dev.conf      # Configuration nginx
├── database-dev.conf       # Configuration PostgreSQL
└── cache-dev.conf          # Configuration Redis

inventory-dev.json          # Inventaire au format JSON
```

---

## 🐛 Dépannage

**Erreur: "Error reading config template file"**
```bash
# Vérifier les templates
ls -la templates/
```

**Erreur: "Resource already exists in state"**
```bash
terraform state rm <resource>
```

**Erreur: "Incompatible Terraform version"**
```bash
# Mettre à jour Terraform
terraform version
# Installer version >= 1.0 depuis https://www.terraform.io/downloads
```

---

## 📚 Prochaines Étapes

1. Modifier `terraform.tfvars` avec vos propres valeurs
2. Ajouter une nouvelle variable dans `variables.tf`
3. Créer un nouveau module dans `modules/`
4. Utiliser `terraform workspace` pour staging/prod
5. Configurer le backend S3 pour le state management en équipe

---

## 💡 Bonnes Pratiques Appliquées

✅ Variables avec validation  
✅ Modules réutilisables  
✅ Outputs bien documentés  
✅ Tags standardisés  
✅ .gitignore pour secrets  
✅ Commentaires explicatifs  
✅ Naming conventions cohérentes  
✅ État centralisé (terraform.tfstate)  

---

**Créé pour la formation DevOps/SRE - Jaouad**
