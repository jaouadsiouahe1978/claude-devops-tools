# KVM/libvirt - Serveur de Virtualisation Léger

## 📋 Description

Configuration et gestion d'une infrastructure de virtualisation légère avec **KVM** (Kernel-based Virtual Machine) et **libvirt**. Ce projet te montre comment :
- Installer et configurer KVM/libvirt sur un serveur Linux
- Créer et gérer des machines virtuelles (VM)
- Configurer la mise en réseau des VMs (bridge et NAT)
- Automatiser le démarrage des VMs avec virsh
- Monitorer l'utilisation des ressources (CPU, RAM)

Ce projet est idéal pour comprendre la virtualisation au niveau système et gérer des environnements de test multi-serveurs.

## 🎯 Objectif

À la fin de ce projet, tu pourras :
- Déployer un hyperviseur KVM/libvirt fonctionnel
- Créer des VMs Ubuntu/CentOS automatiquement
- Configurer le réseau, les storage pools et les snapshots
- Écrire des scripts de gestion et de monitoring
- Utiliser `virsh` pour administrer les VMs

## 🛠 Technos Utilisées

- **KVM** : Hyperviseur Linux natif (virtualisation)
- **libvirt** : API de gestion de virtualisation
- **virsh** : CLI pour gérer les VMs
- **virt-install** : Création automatisée de VMs
- **QEMU** : Émulateur utilisé par KVM
- **Bash** : Scripts d'automatisation
- **UFW/iptables** : Firewall et réseau

## 📋 Pré-requis

- Serveur/PC Linux avec CPU supportant la virtualisation (Intel VT-x ou AMD-V)
- Au minimum 8 GB RAM (16+ recommandé)
- 50+ GB d'espace disque
- Accès sudo/root
- Distribution Linux (Ubuntu 22.04+ ou CentOS 9+)

Vérifier le support CPU :
```bash
grep -E "vmx|svm" /proc/cpuinfo
```

## 🚀 Étapes de Réalisation

### 1. Installation et Configuration de KVM/libvirt

```bash
# Sur Ubuntu 22.04+
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
  virt-manager virt-viewer bridge-utils cpu-checker

# Vérifier l'installation
kvm-ok
virsh version

# Activer et démarrer le service
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Ajouter l'utilisateur au groupe libvirt
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
newgrp libvirt
```

### 2. Configuration du Réseau

#### a) Bridge réseau (recommandé pour la production)
```bash
# Créer un bridge virsh
virsh net-define bridge-net.xml
virsh net-autostart bridge-net
virsh net-start bridge-net
```

#### b) NAT (par défaut, plus simple)
```bash
virsh net-list --all
virsh net-autostart default
virsh net-start default
```

### 3. Créer une Image de Base

Télécharger une image cloud (plus rapide que une installation full) :
```bash
cd /var/lib/libvirt/images/
sudo wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

### 4. Créer des VMs Automatiquement

Utiliser `virt-install` pour créer des VMs :
```bash
sudo virt-install \
  --name ubuntu-vm1 \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20 \
  --network network:default \
  --os-variant ubuntu22.04 \
  --import \
  --graphics none \
  --console pty,target_type=serial
```

### 5. Gestion des VMs

```bash
# Lister les VMs
virsh list --all

# Démarrer/arrêter/redémarrer
virsh start ubuntu-vm1
virsh shutdown ubuntu-vm1
virsh reboot ubuntu-vm1

# Supprimer une VM
virsh undefine ubuntu-vm1 --remove-all-storage

# Console VNC/Serial
virsh console ubuntu-vm1

# Info détaillées
virsh dominfo ubuntu-vm1
virsh domblklist ubuntu-vm1
virsh domiflist ubuntu-vm1
```

### 6. Snapshots et Clonage

```bash
# Créer un snapshot
virsh snapshot-create-as ubuntu-vm1 snap1 "Backup avant maj"

# Lister les snapshots
virsh snapshot-list ubuntu-vm1

# Revenir à un snapshot
virsh snapshot-revert ubuntu-vm1 snap1

# Cloner une VM
virt-clone --original ubuntu-vm1 --name ubuntu-vm2 --auto-clone
```

### 7. Monitoring et Performance

```bash
# Stats CPU/RAM en temps réel
virsh domstats --raw ubuntu-vm1

# Bande passante réseau
virsh domstats --interface ubuntu-vm1

# Espace disque
virsh domblkinfo ubuntu-vm1 vda

# Utilisation globale
virt-top
```

## 📚 Ce qu'on Apprend

✅ Architecture de virtualisation Linux (KVM/QEMU)  
✅ Gestion hyperviseur et ressources VM (CPU, RAM, disque)  
✅ Réseaux virtuels (NAT, bridge, vlans)  
✅ Stockage et snapshots pour la récupération  
✅ Scripting d'automatisation pour infrastructure rapide  
✅ Monitoring et performance des VMs  
✅ Cas d'usage : lab de test, petit datacenter, CI/CD, VPN privé

## 🎓 Extensions Possibles

- Intégrer avec **Terraform** pour IaC (terraform-libvirt-provider)
- Monitoring avec **Prometheus** (libvirt exporter)
- **Proxmox VE** (couche web sur KVM/libvirt)
- Haute disponibilité avec **Pacemaker**
- Backup automatisé avec **Bacula/Backuppc**
- Container KVM intégrés avec **Kata Containers**

## 📌 Ressources

- [KVM/libvirt Documentation](https://www.linux-kvm.org/)
- [libvirt API & Tools](https://libvirt.org/)
- [Proxmox VE (alternative web-based)](https://www.proxmox.com/)
- [virt-manager GUI](https://virt-manager.org/)
