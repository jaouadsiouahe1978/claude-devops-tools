#!/bin/bash

# ============================================================================
# Script: test-persistence.sh
# Description: Test complet de la persistance des données après crash
# Usage: bash scripts/test-persistence.sh
# ============================================================================

set -e

NAMESPACE="postgresql"
POD_NAME="postgres-0"

echo "🧪 Test de persistance des données"
echo "=================================="
echo ""

# Étape 1: Vérifier que le pod est prêt
echo "1️⃣  Attendre que le pod soit prêt..."
kubectl wait --for=condition=ready pod/$POD_NAME -n $NAMESPACE --timeout=300s

echo "✅ Pod prêt!"
echo ""

# Étape 2: Insérer des données
echo "2️⃣  Insertion de données de test..."
bash scripts/insert-data.sh
echo ""

# Étape 3: Vérifier les données
echo "3️⃣  Vérification des données avant crash..."
bash scripts/check-data.sh
echo ""

# Étape 4: Simuler un crash
echo "4️⃣  Simulation d'un crash du pod..."
echo "   -> Suppression de $POD_NAME"
kubectl delete pod $POD_NAME -n $NAMESPACE

echo "   -> Attente de la recréation du pod..."
sleep 5
kubectl wait --for=condition=ready pod/$POD_NAME -n $NAMESPACE --timeout=300s
echo ""

# Étape 5: Vérifier la persistance des données
echo "5️⃣  Vérification de la persistance après crash..."
bash scripts/check-data.sh
echo ""

echo "🎉 Test de persistance terminé avec succès!"
echo "Les données ont survécu au crash du pod!"
