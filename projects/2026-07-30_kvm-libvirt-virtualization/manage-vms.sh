#!/bin/bash
# Script de gestion centralisée des VMs KVM
# Contrôle: démarrage, arrêt, suppression, snapshots

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat << EOF
${YELLOW}Usage:${NC} $0 <command> [options]

${YELLOW}Commandes:${NC}
  list                    Lister toutes les VMs
  info <vm_name>          Afficher les infos détaillées
  start <vm_name>         Démarrer une VM
  stop <vm_name>          Arrêter une VM
  restart <vm_name>       Redémarrer une VM
  delete <vm_name>        Supprimer une VM
  clone <source> <target> Cloner une VM
  snapshot <vm_name>      Créer un snapshot
  snapshot-list <vm_name> Lister les snapshots
  snapshot-revert <vm> <snap> Revenir à un snapshot
  console <vm_name>       Accéder à la console série
  autostart [on|off]      Gérer l'autostart des VMs

${YELLOW}Exemples:${NC}
  $0 list
  $0 start web-server
  $0 snapshot db-server
  $0 clone ubuntu-base web-server1
  $0 delete test-vm
EOF
}

check_vm_exists() {
    if ! virsh list --all --name 2>/dev/null | grep -q "^${1}$"; then
        echo -e "${RED}Erreur: VM '$1' n'existe pas${NC}"
        exit 1
    fi
}

list_vms() {
    echo -e "${YELLOW}=== VMs disponibles ===${NC}"
    virsh list --all
}

show_info() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${YELLOW}=== Infos: $vm ===${NC}"
    virsh dominfo "$vm"
    echo ""
    echo -e "${YELLOW}Disques:${NC}"
    virsh domblklist "$vm"
    echo ""
    echo -e "${YELLOW}Interfaces réseau:${NC}"
    virsh domiflist "$vm"
}

start_vm() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${YELLOW}Démarrage de $vm...${NC}"
    virsh start "$vm" && echo -e "${GREEN}✓ VM démarrée${NC}"
}

stop_vm() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${YELLOW}Arrêt gracieux de $vm...${NC}"
    virsh shutdown "$vm"

    # Attendre l'arrêt (max 30s)
    local count=0
    while [[ $(virsh domstate "$vm" 2>/dev/null) == "running" ]] && (( count < 30 )); do
        sleep 1
        ((count++))
    done

    if [[ $(virsh domstate "$vm" 2>/dev/null) == "running" ]]; then
        echo -e "${YELLOW}⚠️  VM ne s'arrête pas, forçage...${NC}"
        virsh destroy "$vm"
    fi
    echo -e "${GREEN}✓ VM arrêtée${NC}"
}

restart_vm() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${YELLOW}Redémarrage de $vm...${NC}"
    stop_vm "$vm"
    sleep 2
    start_vm "$vm"
    echo -e "${GREEN}✓ VM redémarrée${NC}"
}

delete_vm() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${RED}⚠️  Suppression de $vm et ses données!${NC}"
    read -p "Confirmer (oui/non): " -r
    if [[ $REPLY == "oui" ]]; then
        stop_vm "$vm"
        echo -e "${YELLOW}Suppression...${NC}"
        virsh undefine "$vm" --remove-all-storage
        echo -e "${GREEN}✓ VM supprimée${NC}"
    else
        echo "Annulé"
    fi
}

clone_vm() {
    local source="$1"
    local target="$2"

    if [[ -z "$target" ]]; then
        echo -e "${RED}Erreur: Nom de la VM cible manquant${NC}"
        exit 1
    fi

    check_vm_exists "$source"

    if virsh list --all --name 2>/dev/null | grep -q "^${target}$"; then
        echo -e "${RED}Erreur: VM '$target' existe déjà${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Clonage de $source vers $target...${NC}"
    virt-clone --original "$source" --name "$target" --auto-clone && \
    echo -e "${GREEN}✓ VM clonée${NC}"
}

create_snapshot() {
    local vm="$1"
    local snap_name="${2:-snap-$(date +%s)}"
    local description="${3:-Snapshot créé le $(date)}"

    check_vm_exists "$vm"

    echo -e "${YELLOW}Création d'un snapshot...${NC}"
    virsh snapshot-create-as "$vm" "$snap_name" "$description" && \
    echo -e "${GREEN}✓ Snapshot créé: $snap_name${NC}"
}

list_snapshots() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${YELLOW}=== Snapshots: $vm ===${NC}"
    virsh snapshot-list "$vm"
}

revert_snapshot() {
    local vm="$1"
    local snapshot="$2"

    if [[ -z "$snapshot" ]]; then
        echo -e "${RED}Erreur: Nom du snapshot manquant${NC}"
        exit 1
    fi

    check_vm_exists "$vm"

    echo -e "${YELLOW}Revert vers $snapshot...${NC}"
    virsh snapshot-revert "$vm" "$snapshot" && \
    echo -e "${GREEN}✓ Reverted${NC}"
}

access_console() {
    local vm="$1"
    check_vm_exists "$vm"

    echo -e "${YELLOW}Console de $vm (Ctrl+] pour quitter)...${NC}"
    virsh console "$vm"
}

manage_autostart() {
    local action="${1:-status}"

    case "$action" in
        on)
            echo -e "${YELLOW}Activation autostart pour toutes les VMs...${NC}"
            for vm in $(virsh list --all --name); do
                [[ -n "$vm" ]] && virsh autostart "$vm"
            done
            echo -e "${GREEN}✓ Autostart activé${NC}"
            ;;
        off)
            echo -e "${YELLOW}Désactivation autostart pour toutes les VMs...${NC}"
            for vm in $(virsh list --all --name); do
                [[ -n "$vm" ]] && virsh autostart --disable "$vm"
            done
            echo -e "${GREEN}✓ Autostart désactivé${NC}"
            ;;
        *)
            echo -e "${YELLOW}=== Statut autostart ===${NC}"
            for vm in $(virsh list --all --name); do
                if [[ -n "$vm" ]]; then
                    local status=$(virsh dominfo "$vm" | grep "Autostart" | awk '{print $2}')
                    echo "$vm: $status"
                fi
            done
            ;;
    esac
}

# Parsing des commandes
if [[ -z "$1" ]]; then
    usage
    exit 0
fi

case "$1" in
    list)
        list_vms
        ;;
    info)
        show_info "$2"
        ;;
    start)
        start_vm "$2"
        ;;
    stop)
        stop_vm "$2"
        ;;
    restart)
        restart_vm "$2"
        ;;
    delete)
        delete_vm "$2"
        ;;
    clone)
        clone_vm "$2" "$3"
        ;;
    snapshot)
        create_snapshot "$2" "$3" "$4"
        ;;
    snapshot-list)
        list_snapshots "$2"
        ;;
    snapshot-revert)
        revert_snapshot "$2" "$3"
        ;;
    console)
        access_console "$2"
        ;;
    autostart)
        manage_autostart "$2"
        ;;
    *)
        echo -e "${RED}Commande inconnue: $1${NC}"
        usage
        exit 1
        ;;
esac
