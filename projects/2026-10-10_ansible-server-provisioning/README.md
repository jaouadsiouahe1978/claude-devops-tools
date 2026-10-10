# Ansible Server Provisioning

## 📚 Objectif
Automatiser la configuration et la provisioning d'un serveur Linux avec Ansible. Créer des playbooks pour installer et configurer les services essentiels d'un serveur web production.

## 🛠️ Technologies
- Ansible
- Linux (Ubuntu/CentOS)
- Docker (optionnel)
- SSH
- YAML

## 🚀 Installation & Utilisation

### Prérequis
```bash
# Installer Ansible
sudo apt-get install ansible -y

# Générer une clé SSH (si nécessaire)
ssh-keygen -t rsa -b 4096

# Copier la clé sur le serveur cible
ssh-copy-id user@target-server
```

### Étapes de réalisation

1. **Vérifier la connectivité**
```bash
cd projects/2026-10-10_ansible-server-provisioning
ansible all -i inventory.ini -m ping
```

2. **Exécuter le playbook principal**
```bash
ansible-playbook -i inventory.ini site.yml
```

3. **Exécuter un rôle spécifique**
```bash
ansible-playbook -i inventory.ini site.yml --tags "webserver"
```

4. **Mode verbeux pour debug**
```bash
ansible-playbook -i inventory.ini site.yml -vv
```

## 📁 Structure du Projet

```
2026-10-10_ansible-server-provisioning/
├── inventory.ini              # Fichier d'inventaire des hôtes
├── site.yml                   # Playbook principal
├── roles/
│   ├── common/                # Rôle pour configuration commune
│   ├── webserver/             # Rôle pour serveur web (Nginx)
│   └── monitoring/            # Rôle pour monitoring basique
└── group_vars/
    └── all.yml               # Variables globales
```

## 📖 Ce qu'on apprend

- **Infrastructure as Code** : Gérer les serveurs comme du code avec Ansible
- **Idempotence** : Les playbooks peuvent être exécutés plusieurs fois sans risque
- **Rôles Ansible** : Organiser et réutiliser la configuration
- **Gestion d'inventaire** : Gérer plusieurs serveurs efficacement
- **Best practices DevOps** : Automatisation, reproductibilité, scalabilité
- **Configuration management** : Maintenance et mise à jour centralisée
- **Variables et templates** : Paramétrer les configurations

## 🎯 Cas d'usage pratiques

1. **Déployer rapidement** : Provisionner 10 serveurs identiques en minutes
2. **Maintenir la cohérence** : S'assurer que tous les serveurs ont la même configuration
3. **Disaster Recovery** : Recréer une infrastructure rapidement après une panne
4. **Scaling automatisé** : Ajouter de nouveaux serveurs avec la même config

## 🔥 Améliorations possibles

- Ajouter des handlers pour redémarrer les services
- Implémenter le versioning des packages
- Utiliser Ansible Vault pour les secrets
- Intégrer avec Terraform pour la gestion d'infrastructure
- Ajouter des tests avec Molecule
- Créer une pipeline CI/CD pour valider les playbooks

---
**Créé le:** 2026-10-10  
**Durée:** 1 journée  
**Niveau:** Débutant à Intermédiaire  
**Prérequis:** Connaissance basique de Linux et SSH
