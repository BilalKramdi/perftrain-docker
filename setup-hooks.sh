#!/bin/sh

# Script pour installer les hooks Git

echo "🔗 Installation des hooks Git..."

# Créer le répertoire hooks s'il n'existe pas
mkdir -p .git/hooks

# Copier les hooks
cp .githooks/pre-push .git/hooks/
cp .githooks/post-commit .git/hooks/

# Rendre les hooks exécutables
chmod +x .git/hooks/pre-push
chmod +x .git/hooks/post-commit

echo "✅ Hooks Git installés:"
echo "   - pre-push: Validation des migrations Hasura"
echo "   - post-commit: Sauvegarde automatique"

echo ""
echo "🚀 Pour activer complètement le système:"
echo "1. Démarrez les services: docker-compose up -d"
echo "2. Les migrations seront surveillées automatiquement"
echo "3. Les sauvegardes quotidiennes se feront à 2h du matin"