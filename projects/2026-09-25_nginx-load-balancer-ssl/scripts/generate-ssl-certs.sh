#!/bin/bash
# Script pour générer les certificats SSL/TLS auto-signés

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSL_DIR="$PROJECT_DIR/nginx/ssl"

echo "🔐 Génération des certificats SSL/TLS auto-signés..."

# Créer le répertoire SSL s'il n'existe pas
mkdir -p "$SSL_DIR"

# Paramètres du certificat
DAYS=365
COUNTRY="FR"
STATE="Isere"
CITY="Grenoble"
ORG="DevOps"
CN="localhost"

# Générer la clé privée (2048 bits) et le certificat
openssl req -x509 \
    -newkey rsa:2048 \
    -keyout "$SSL_DIR/nginx.key" \
    -out "$SSL_DIR/nginx.crt" \
    -days $DAYS \
    -nodes \
    -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=$CN"

echo "✅ Certificat généré avec succès:"
echo "   - Clé privée: $SSL_DIR/nginx.key"
echo "   - Certificat: $SSL_DIR/nginx.crt"
echo "   - Validité: $DAYS jours"
echo "   - CN: $CN"

# Afficher les informations du certificat
echo ""
echo "📋 Détails du certificat:"
openssl x509 -in "$SSL_DIR/nginx.crt" -text -noout | grep -E "Subject:|Issuer:|Not Before|Not After"

# Vérifier la paire clé-certificat
echo ""
echo "🔍 Vérification de la paire clé-certificat..."
CERT_MODULUS=$(openssl x509 -noout -modulus -in "$SSL_DIR/nginx.crt" | openssl md5)
KEY_MODULUS=$(openssl rsa -noout -modulus -in "$SSL_DIR/nginx.key" | openssl md5)

if [ "$CERT_MODULUS" = "$KEY_MODULUS" ]; then
    echo "✅ La clé et le certificat correspondent!"
else
    echo "❌ Erreur: La clé et le certificat ne correspondent pas!"
    exit 1
fi

# Définir les permissions
chmod 600 "$SSL_DIR/nginx.key"
chmod 644 "$SSL_DIR/nginx.crt"

echo ""
echo "🎉 Certificats SSL/TLS générés avec succès!"
echo "   Vous pouvez maintenant démarrer l'infrastructure avec: docker-compose up -d"
