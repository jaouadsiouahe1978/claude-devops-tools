#!/bin/bash
# Setup-lab.sh - Crée un environnement de test local avec Vagrant et VirtualBox

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🏗️  Setup Ansible Lab Environment"
echo "=================================="
echo ""

# Vérifier les dépendances
check_dependency() {
    if command -v $1 &> /dev/null; then
        echo "✓ $1 installé"
        return 0
    else
        echo "❌ $1 n'est pas installé"
        return 1
    fi
}

echo "Vérification des dépendances..."
has_vagrant=$(check_dependency vagrant)
has_virtualbox=$(check_dependency virtualbox)

if [ "$has_vagrant" -eq 0 ] && [ "$has_virtualbox" -eq 0 ]; then
    echo ""
    echo "Création des VMs..."

    # Créer Vagrantfile
    cat > "$PROJECT_DIR/Vagrantfile" << 'EOF'
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_version = "20240101.0.0"

  # Web Server 1
  config.vm.define "web1" do |web1|
    web1.vm.hostname = "web1"
    web1.vm.network "private_network", ip: "192.168.1.101"
    web1.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  # Web Server 2
  config.vm.define "web2" do |web2|
    web2.vm.hostname = "web2"
    web2.vm.network "private_network", ip: "192.168.1.102"
    web2.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  # Database Server
  config.vm.define "db1" do |db1|
    db1.vm.hostname = "db1"
    db1.vm.network "private_network", ip: "192.168.1.103"
    db1.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
  end

  # Monitoring Server
  config.vm.define "mon1" do |mon1|
    mon1.vm.hostname = "mon1"
    mon1.vm.network "private_network", ip: "192.168.1.104"
    mon1.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
  end
end
EOF

    echo "✓ Vagrantfile créé"
    echo ""
    echo "Démarrage des VMs (cela peut prendre quelques minutes)..."
    cd "$PROJECT_DIR"
    vagrant up

    echo ""
    echo "✅ Lab setup terminé!"
    echo ""
    echo "Commandes utiles:"
    echo "  vagrant status    # Voir l'état des VMs"
    echo "  vagrant ssh web1  # Se connecter à web1"
    echo "  vagrant halt      # Arrêter les VMs"
    echo "  vagrant destroy   # Supprimer les VMs"

else
    echo ""
    echo "Pour utiliser Vagrant, installez:"
    echo "  sudo apt-get install vagrant virtualbox"
    echo ""
    echo "Ou configurez manuellement dans inventory/hosts.yml"
fi

echo ""
echo "Prochaines étapes:"
echo "  1. Modifier inventory/hosts.yml avec vos IP"
echo "  2. ./scripts/test-playbook.sh"
echo "  3. ansible-playbook -i inventory/hosts.yml playbooks/site.yml -v"
