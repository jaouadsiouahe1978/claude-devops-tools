# Linux Advanced System Administration - User & Permission Management

## Description
Ce projet couvre les mécanismes avancés de gestion des permissions et des utilisateurs sous Linux, essentiels pour sécuriser les environnements DevOps. Vous apprendrez à gérer les comptes utilisateurs, les groupes, les ACLs (Access Control Lists), et les configurations sudo pour un contrôle d'accès granulaire.

**Technos utilisées:** Linux, ACLs, sudoers, user management, group management

## Objectifs pédagogiques
- Créer et gérer des utilisateurs et groupes Linux
- Configurer les permissions standard (rwx) et avancées (ACLs)
- Implémenter une stratégie sudo personnalisée et sécurisée
- Automatiser la gestion des permissions avec des scripts
- Auditer et monitorer les accès aux fichiers critiques

## Pré-requis
- Ubuntu/Debian ou autre distribution Linux
- Accès root ou sudo
- Connaissance basique des commandes Linux (ls, chmod, chown)

## Structure du projet

```
.
├── README.md                          # Ce fichier
├── setup.sh                           # Script d'installation complet
├── users/
│   ├── create_users.sh               # Créer utilisateurs et groupes
│   ├── password_policy.sh            # Politique de mots de passe
│   └── user_audit.sh                 # Audit des comptes utilisateurs
├── permissions/
│   ├── standard_permissions.sh       # Permissions rwx standards
│   ├── acl_setup.sh                  # Configuration des ACLs
│   └── acl_audit.sh                  # Audit des ACLs
├── sudoers/
│   ├── sudoers_config                # Configuration sudoers sécurisée
│   ├── setup_sudo.sh                 # Script de configuration sudo
│   └── sudo_audit.sh                 # Audit des commandes sudo
├── scenarios/
│   ├── scenario1_webapp_access.sh    # Cas: Application web multi-user
│   ├── scenario2_devops_team.sh      # Cas: Équipe DevOps avec droits différents
│   └── scenario3_compliance.sh       # Cas: Conformité et audit
└── tests/
    └── test_permissions.sh            # Suite de tests

```

## Étapes de réalisation

### 1. Préparation de l'environnement
```bash
cd /home/user/claude-devops-tools/projects/2026-07-16_linux-advanced-permissions
chmod +x *.sh */*.sh

# Exécuter le setup complet
sudo ./setup.sh
```

### 2. Gestion des utilisateurs et groupes
```bash
# Créer utilisateurs et groupes
sudo ./users/create_users.sh

# Appliquer la politique de mots de passe
sudo ./users/password_policy.sh

# Auditer les comptes créés
./users/user_audit.sh
```

### 3. Configuration des permissions
```bash
# Appliquer les permissions standards
sudo ./permissions/standard_permissions.sh

# Configurer les ACLs pour accès granulaire
sudo ./permissions/acl_setup.sh

# Vérifier les ACLs
./permissions/acl_audit.sh
```

### 4. Configuration sudo avancée
```bash
# Configurer sudo sans mot de passe pour certaines commandes
sudo ./sudoers/setup_sudo.sh

# Auditer la configuration sudo
./sudoers/sudo_audit.sh
```

### 5. Tester les scénarios réalistes
```bash
# Scénario 1: Accès à une application web
sudo ./scenarios/scenario1_webapp_access.sh

# Scénario 2: Équipe DevOps avec rôles différents
sudo ./scenarios/scenario2_devops_team.sh

# Scénario 3: Conformité et audit complet
sudo ./scenarios/scenario3_compliance.sh
```

### 6. Tester les permissions
```bash
# Lancer la suite de tests
./tests/test_permissions.sh
```

## Ce qu'on apprend

### Concepts clés

**Permissions Linux (rwx):**
- Read (r=4): Lecture du fichier ou listing du répertoire
- Write (w=2): Modification ou suppression du fichier
- Execute (x=1): Exécution du fichier ou accès au répertoire

**ACLs (Access Control Lists):**
- Dépassent les limitations des permissions rwx
- Permettent d'accorder des droits à plusieurs utilisateurs/groupes
- Syntaxe: `setfacl -m u:username:rwx /path/to/file`

**Sudo (superuser do):**
- Exécuter une commande avec des droits élevés sans être root
- Configuration granulaire: utilisateurs, groupes, commandes spécifiques
- Sans mot de passe pour actions automatisées (scripts CI/CD)

**Audit de sécurité:**
- Vérifier les permissions sensibles
- Monitorer les accès en lecture et écriture
- Détecter les configurations dangereuses

## Cas d'usage pratiques

### 1. Application web multi-user
Situation: Une application web (nginx) doit servir des fichiers de plusieurs utilisateurs sans qu'ils puissent se voir les fichiers respectifs.

**Solution:** ACLs + umask personnalisé

### 2. Équipe DevOps
Situation: Les développeurs doivent pouvoir redémarrer certains services, les ops doivent administrer complètement, les juniors ont accès limité.

**Solution:** Sudo + groupes Linux

### 3. Conformité (GDPR, ISO 27001)
Situation: Audit régulier des accès, journalisation des modifications, principe du moindre privilège.

**Solution:** Script d'audit automatisé + logging

## Points importants

⚠️ **Sécurité:**
- Ne jamais donner les droits root sans raison
- Utiliser sudo avec des commandes spécifiques, jamais `ALL`
- Auditer régulièrement les permissions sensibles
- Logs de sudo: `/var/log/auth.log` ou `/var/log/secure`

📋 **Bonnes pratiques:**
- Utiliser des groupes pour gérer les permissions (plus maintenable)
- Documenter chaque changement de permission
- Tester avant d'appliquer en production
- Sauvegarder les configurations sudoers

## Commandes essentielles

```bash
# Utilisateurs et groupes
useradd -m -s /bin/bash -G docker,sudo username   # Créer utilisateur
usermod -aG groupname username                     # Ajouter à un groupe
deluser username                                   # Supprimer utilisateur
getent group groupname                             # Lister membres d'un groupe

# Permissions
chmod 755 /path/to/file                            # Permissions rwx
chown user:group /path/to/file                     # Changer propriétaire
umask 0022                                         # Umask par défaut

# ACLs
setfacl -m u:user:rwx /path/to/file               # Accorder droits ACL
setfacl -m g:group:rx /path/to/file               # ACL pour groupe
setfacl -m d:u:user:rwx /path/to/dir              # ACL défaut sur répertoire
getfacl /path/to/file                              # Afficher ACLs

# Sudo
sudo visudo                                        # Éditer /etc/sudoers (safe)
sudo -l                                            # Lister les droits sudo
sudo -u username command                           # Exécuter en tant que user
```

## Pour aller plus loin

- **SELinux / AppArmor:** Contrôle d'accès obligatoire (MAC)
- **File Capabilities:** Alternatives plus fines à setuid/setgid
- **Audit daemon:** Enregistrement détaillé des accès aux fichiers
- **LDAP/Active Directory:** Gestion centralisée des utilisateurs
- **Container permissions:** Permissions dans les conteneurs Docker/Kubernetes

## Ressources

- [Linux Permissions Explained](https://www.linux.com/tutorials/understanding-linux-file-permissions/)
- [ACLs on Linux](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/sec-working_with_acls)
- [Sudoers Manual](https://www.man7.org/linux/man-pages/man5/sudoers.5.html)
- [RHEL Security Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/)

---
**Créé pour:** Jaouad - Formation DevOps/SRE à Grenoble
**Date:** 2026-07-16
