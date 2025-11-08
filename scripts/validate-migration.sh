#!/bin/sh

# Script de validation des migrations Hasura
# Vérifie qu'une migration ne contient pas d'opérations dangereuses

set -e

if [ "$#" -ne 1 ]; then
    echo "❌ Usage: $0 <migration_file.sql>"
    exit 1
fi

MIGRATION_FILE="$1"

echo "🔍 Validation de la migration: $MIGRATION_FILE"

# Vérifier que le fichier existe
if [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Fichier de migration non trouvé: $MIGRATION_FILE"
    exit 1
fi

# Liste des opérations dangereuses
DANGEROUS_OPERATIONS="
DROP TABLE
DROP DATABASE
DROP SCHEMA
TRUNCATE
DELETE FROM.*WHERE.*1=1
DELETE FROM.*WHERE.*TRUE
DROP COLUMN
ALTER COLUMN.*DROP
"

# Variables pour les warnings et erreurs
WARNINGS=0
ERRORS=0

echo "🔍 Analyse du contenu de la migration..."

# Vérifier les opérations dangereuses
for operation in $DANGEROUS_OPERATIONS; do
    if grep -i "$operation" "$MIGRATION_FILE" > /dev/null; then
        echo "⚠️  ATTENTION: Opération potentiellement dangereuse détectée: $operation"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# Vérifications spécifiques
echo "🔍 Vérifications de sécurité..."

# Vérifier les DROP TABLE
if grep -i "DROP TABLE" "$MIGRATION_FILE" > /dev/null; then
    echo "❌ ERREUR: DROP TABLE détecté - cela supprimera des données!"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier les TRUNCATE
if grep -i "TRUNCATE" "$MIGRATION_FILE" > /dev/null; then
    echo "❌ ERREUR: TRUNCATE détecté - cela supprimera des données!"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier les DELETE massifs
if grep -i -E "DELETE FROM.*WHERE.*(1=1|TRUE)" "$MIGRATION_FILE" > /dev/null; then
    echo "❌ ERREUR: DELETE massif détecté!"
    ERRORS=$((ERRORS + 1))
fi

# Vérifier la syntaxe SQL basique
echo "🔍 Vérification de la syntaxe SQL..."

# Compter les instructions
STATEMENTS=$(grep -c ";" "$MIGRATION_FILE" || echo "0")
echo "📊 Nombre d'instructions SQL: $STATEMENTS"

# Résumé
echo ""
echo "📋 Résumé de la validation:"
echo "   Warnings: $WARNINGS"
echo "   Erreurs: $ERRORS"

if [ $ERRORS -gt 0 ]; then
    echo "❌ VALIDATION ÉCHOUÉE: La migration contient des opérations dangereuses!"
    echo "🚫 Cette migration ne devrait PAS être appliquée en production."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  VALIDATION AVEC WARNINGS: Veuillez vérifier les opérations signalées."
    echo "🔍 Recommandation: Tester en environnement de test avant production."
    exit 2
else
    echo "✅ VALIDATION RÉUSSIE: La migration semble sûre."
    exit 0
fi