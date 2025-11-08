#!/bin/sh

# Script de sauvegarde automatique PostgreSQL avec rotation

set -e

echo "🗄️  Démarrage de la sauvegarde PostgreSQL - $(date)"

# Variables d'environnement
POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_DB=${POSTGRES_DB:-postgres}
POSTGRES_USER=${POSTGRES_USER:-postgres}
BACKUP_DIR="/backups"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p "$BACKUP_DIR"

# Nom du fichier de sauvegarde avec timestamp
BACKUP_FILE="flirit_backup_$(date +%Y%m%d_%H%M%S).sql"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

# Attendre que PostgreSQL soit prêt
echo "⏳ Vérification de la disponibilité de PostgreSQL..."
until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" > /dev/null 2>&1; do
  echo "PostgreSQL n'est pas encore prêt, attente..."
  sleep 5
done

echo "✅ PostgreSQL est prêt"

# Effectuer la sauvegarde
echo "💾 Création de la sauvegarde: $BACKUP_FILE"
PGPASSWORD="$POSTGRES_PASSWORD" pg_dump \
  -h "$POSTGRES_HOST" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  --verbose \
  --clean \
  --no-owner \
  --no-privileges \
  --format=custom \
  > "$BACKUP_PATH"

if [ $? -eq 0 ]; then
  echo "✅ Sauvegarde créée avec succès: $BACKUP_PATH"
  
  # Compresser la sauvegarde
  gzip "$BACKUP_PATH"
  echo "🗜️  Sauvegarde compressée: $BACKUP_PATH.gz"
  
  # Supprimer les anciennes sauvegardes
  echo "🧹 Nettoyage des anciennes sauvegardes (> $RETENTION_DAYS jours)..."
  find "$BACKUP_DIR" -name "flirit_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
  
  # Afficher l'espace utilisé
  echo "📊 Espace utilisé par les sauvegardes:"
  du -sh "$BACKUP_DIR"
  
  echo "✅ Sauvegarde terminée avec succès - $(date)"
else
  echo "❌ Erreur lors de la sauvegarde"
  exit 1
fi