# Projet DevOps du Jour - 2026-07-30

## 📦 KVM/libvirt - Serveur de Virtualisation Léger

**Catégorie:** Linux Sysadmin | Virtualisation  
**Technos:** KVM, libvirt, QEMU, virsh, Bash scripting

### 🎯 Objectif
Configuration complète d'une infrastructure de virtualisation légère avec KVM (Kernel-based Virtual Machine) et libvirt. Apprendre à déployer, gérer et monitorer des machines virtuelles sur un serveur Linux.

### 📚 Ce qu'on apprend
✅ Architecture de virtualisation Linux (KVM/QEMU)  
✅ Installation et configuration de KVM/libvirt  
✅ Gestion hyperviseur et ressources VM (CPU, RAM, disque)  
✅ Réseaux virtuels (NAT, bridge, configuration avancée)  
✅ Création automatisée de VMs avec virt-install  
✅ Snapshots et clonage pour récupération/tests  
✅ Scripting d'automatisation pour infrastructure rapide  
✅ Monitoring et performance des VMs  
✅ Cas d'usage: lab de test, petit datacenter, CI/CD, VPN privé

### 🛠 Contenu du Projet

**Scripts:**
- `install-kvm.sh` - Installation automatisée de KVM/libvirt sur Ubuntu 22.04+
- `create-vm.sh` - Création rapide de VMs avec paramètres personnalisables
- `manage-vms.sh` - Interface centralisée pour gérer les VMs (start/stop/delete/clone/snapshots)
- `vm-monitoring.sh` - Dashboard temps réel des stats CPU/RAM/disque/réseau

**Configuration:**
- `bridge-net.xml` - Configuration réseau bridge pour la production
- `nat-network.xml` - Configuration réseau NAT simple pour testing

**Documentation:**
- `README.md` - Guide complet avec pré-requis, étapes et commandes

### ⚡ Quick Start
```bash
# Installation
sudo ./install-kvm.sh

# Créer une VM
./create-vm.sh web-server 2048 2 20

# Gérer les VMs
./manage-vms.sh list
./manage-vms.sh start web-server
./manage-vms.sh snapshot web-server backup1
./manage-vms.sh clone web-server web-server2

# Monitoring en temps réel
./vm-monitoring.sh 2 web-server
```

### 🚀 Prochaines Étapes
1. Intégrer avec **Terraform** pour IaC (terraform-libvirt-provider)
2. Monitoring avec **Prometheus** (libvirt exporter)
3. Proxmox VE (couche web sur KVM/libvirt)
4. Haute disponibilité avec **Pacemaker**
5. Backup automatisé avec **Bacula**

**Niveau:** Débutant à Intermédiaire  
**Durée:** ~1 journée  
**Prérequis:** CPU avec VT-x/AMD-V, 8GB+ RAM, 50GB+ disque

---
**Repository:** https://github.com/jaouadsiouahe1978/claude-devops-tools  
**Dossier:** `projects/2026-07-30_kvm-libvirt-virtualization/`
