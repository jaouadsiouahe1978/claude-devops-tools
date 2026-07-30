#!/bin/bash
# Script de création automatisée de VMs avec KVM
# Usage: ./create-vm.sh <nom_vm> <ram_mb> <vcpus> <disk_gb> [image_url]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Valeurs par défaut
DEFAULT_RAM=2048
DEFAULT_VCPUS=2
DEFAULT_DISK=20
DEFAULT_IMAGE="ubuntu22.04"
IMAGES_DIR="/var/lib/libvirt/images"

usage() {
    cat << EOF
${YELLOW}Usage:${NC} $0 <nom_vm> [ram_mb] [vcpus] [disk_gb] [image]

Paramètres :
  nom_vm      : Nom unique de la VM (requis)
  ram_mb      : RAM en MB (défaut: $DEFAULT_RAM)
  vcpus       : Nombre de vCPU (défaut: $DEFAULT_VCPUS)
  disk_gb     : Taille disque en GB (défaut: $DEFAULT_DISK)
  image       : Type image (ubuntu22.04, ubuntu20.04, centos9, debian12)
                (défaut: $DEFAULT_IMAGE)

Exemples :
  $0 web-server
  $0 db-server 4096 4 50
  $0 test-vm 2048 2 20 centos9

${YELLOW}Images disponibles:${NC}
  ubuntu22.04  : Ubuntu 22.04 LTS Jammy
  ubuntu20.04  : Ubuntu 20.04 LTS Focal
  centos9      : CentOS Stream 9
  debian12     : Debian 12 Bookworm
EOF
}

# Vérifier les paramètres
if [[ -z "$1" ]]; then
    echo -e "${RED}Erreur: Nom de VM manquant${NC}"
    usage
    exit 1
fi

VM_NAME="$1"
RAM_MB="${2:-$DEFAULT_RAM}"
VCPUS="${3:-$DEFAULT_VCPUS}"
DISK_GB="${4:-$DEFAULT_DISK}"
OS_VARIANT="${5:-$DEFAULT_IMAGE}"

# Validation du nom de VM
if virsh list --all --name 2>/dev/null | grep -q "^${VM_NAME}$"; then
    echo -e "${RED}Erreur: VM '$VM_NAME' existe déjà${NC}"
    exit 1
fi

# Vérifier que libvirt est actif
if ! virsh list >/dev/null 2>&1; then
    echo -e "${RED}Erreur: libvirtd n'est pas accessible${NC}"
    echo "Lancez: sudo systemctl start libvirtd"
    exit 1
fi

echo -e "${YELLOW}=== Création de VM KVM ===${NC}"
echo -e "VM Name      : ${BLUE}$VM_NAME${NC}"
echo -e "RAM          : ${BLUE}${RAM_MB} MB${NC}"
echo -e "vCPUs        : ${BLUE}$VCPUS${NC}"
echo -e "Disk         : ${BLUE}${DISK_GB} GB${NC}"
echo -e "OS Variant   : ${BLUE}$OS_VARIANT${NC}"
echo ""

# Créer le répertoire images s'il n'existe pas
if [[ ! -d "$IMAGES_DIR" ]]; then
    echo -e "${YELLOW}[1/3] Création du répertoire images...${NC}"
    sudo mkdir -p "$IMAGES_DIR"
fi

# Préparer le disque
DISK_PATH="$IMAGES_DIR/${VM_NAME}.qcow2"
echo -e "${YELLOW}[2/3] Création du disque ($DISK_PATH)...${NC}"
sudo qemu-img create -f qcow2 "$DISK_PATH" "${DISK_GB}G"

# Créer la VM avec virt-install
echo -e "${YELLOW}[3/3] Création de la VM...${NC}"
sudo virt-install \
    --name "$VM_NAME" \
    --memory "$RAM_MB" \
    --vcpus "$VCPUS" \
    --disk path="$DISK_PATH,format=qcow2" \
    --network network:default \
    --os-variant "$OS_VARIANT" \
    --graphics none \
    --console pty,target_type=serial \
    --nographics \
    --cdrom /dev/null \
    --noautoconsole \
    2>/dev/null || true

echo ""
echo -e "${GREEN}=== VM créée avec succès! ===${NC}"
echo ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "  virsh start $VM_NAME              # Démarrer la VM"
echo "  virsh console $VM_NAME            # Accéder à la console"
echo "  virsh dominfo $VM_NAME            # Infos de la VM"
echo "  virsh snapshot-create-as $VM_NAME snap1 \"description\""
echo "  virt-clone --original $VM_NAME --name ${VM_NAME}2 --auto-clone"
