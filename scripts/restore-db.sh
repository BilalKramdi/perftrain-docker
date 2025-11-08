#!/bin/sh

# Script de restauration PostgreSQL

set -e

if [ "$#" -ne 1 ]; then
    echo "❌ Usage: $0 <backup_file.sql.gz>"
    echo "📁 Sauvegardes disponibles:"
    ls -la /backups/flirit_backup_*.sql.gz 2>/dev/null || echo "Aucune sauvegarde trouvée"
    exit 1
fi

BACKUP_FILE="$1"
BACKUP_PATH="/backups/$BACKUP_FILE"

# Variables d'environnement
POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_DB=${POSTGRES_DB:-postgres}
POSTGRES_USER=${POSTGRES_USER:-postgres}

echo "🔄 Démarrage de la restauration depuis: $BACKUP_FILE"

# Vérifier que le fichier existe
if [ ! -f "$BACKUP_PATH" ]; then
    echo "❌ Fichier de sauvegarde non trouvé: $BACKUP_PATH"
    exit 1
fi

# Attendre que PostgreSQL soit prêt
echo "⏳ Vérification de la disponibilité de PostgreSQL..."
until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" > /dev/null 2>&1; do
  echo "PostgreSQL n'est pas encore prêt, attente..."
  sleep 5
done

echo "✅ PostgreSQL est prêt"

# Décompresser si nécessaire
TEMP_FILE="/tmp/restore_temp.sql"
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "🗜️  Décompression de la sauvegarde..."
    gunzip -c "$BACKUP_PATH" > "$TEMP_FILE"
    RESTORE_FILE="$TEMP_FILE"
else
    RESTORE_FILE="$BACKUP_PATH"
fi

# Demander confirmation
echo "⚠️  ATTENTION: Cette opération va remplacer toutes les données de la base '$POSTGRES_DB'"
echo "🔄 Voulez-vous continuer? (y/N)"
read -r response
if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    echo "❌ Restauration annulée"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Effectuer la restauration
echo "🔄 Restauration en cours..."
PGPASSWORD="$POSTGRES_PASSWORD" pg_restore \
  -h "$POSTGRES_HOST" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  --verbose \
  --clean \
  --if-exists \
  "$RESTORE_FILE"

if [ $? -eq 0 ]; then
  echo "✅ Restauration terminée avec succès"
else
  echo "❌ Erreur lors de la restauration"
  rm -f "$TEMP_FILE"
  exit 1
fi

# Nettoyage
rm -f "$TEMP_FILE"

echo "✅ Restauration complète - $(date)"