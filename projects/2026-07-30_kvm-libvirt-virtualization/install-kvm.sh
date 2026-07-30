#!/bin/bash
# Installation et configuration complète de KVM/libvirt
# Script d'automatisation pour Ubuntu 22.04+

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Installation KVM/libvirt ===${NC}"

# Vérifier si l'utilisateur a les droits sudo
if ! sudo -n true 2>/dev/null; then
    echo -e "${RED}Ce script nécessite les droits sudo${NC}"
    exit 1
fi

# 1. Vérifier le support de la virtualisation
echo -e "${YELLOW}[1/6] Vérification du support CPU...${NC}"
if grep -q -E "vmx|svm" /proc/cpuinfo; then
    echo -e "${GREEN}✓ CPU supporte la virtualisation${NC}"
else
    echo -e "${RED}✗ CPU ne supporte pas la virtualisation (VT-x/AMD-V)${NC}"
    exit 1
fi

# 2. Mettre à jour le système
echo -e "${YELLOW}[2/6] Mise à jour du système...${NC}"
sudo apt update -qq
sudo apt upgrade -y -qq

# 3. Installer les paquets nécessaires
echo -e "${YELLOW}[3/6] Installation des paquets KVM/libvirt...${NC}"
sudo apt install -y -qq \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    virt-manager \
    virt-viewer \
    virt-install \
    bridge-utils \
    cpu-checker \
    cloud-image-utils \
    libosinfo-bin

# 4. Démarrer les services
echo -e "${YELLOW}[4/6] Activation des services...${NC}"
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo systemctl enable virtlogd
sudo systemctl start virtlogd

# 5. Configurer les permissions utilisateur
echo -e "${YELLOW}[5/6] Configuration des permissions...${NC}"
CURRENT_USER=$(whoami)
sudo usermod -aG libvirt "$CURRENT_USER"
sudo usermod -aG kvm "$CURRENT_USER"
echo -e "${GREEN}✓ Utilisateur $CURRENT_USER ajouté aux groupes libvirt et kvm${NC}"

# 6. Vérifier l'installation
echo -e "${YELLOW}[6/6] Vérification de l'installation...${NC}"
kvm-ok
echo ""
virsh version
echo ""

# Afficher la configuration réseau par défaut
echo -e "${YELLOW}Réseaux disponibles:${NC}"
virsh net-list --all

echo ""
echo -e "${GREEN}=== Installation complétée! ===${NC}"
echo -e "${YELLOW}⚠️  Déconnectez-vous et reconnectez-vous pour appliquer les changements de groupes${NC}"
echo ""
echo "Commandes de démarrage :"
echo "  virsh net-autostart default  # Activer le réseau par défaut"
echo "  virsh net-start default      # Démarrer le réseau par défaut"
echo "  virt-install --help          # Créer une VM"
echo "  virsh list --all             # Lister les VMs"
