#!/bin/sh

# Script pour surveiller les changements Hasura et générer automatiquement les migrations

echo "🚀 Démarrage de la surveillance Hasura..."

# Attendre que Hasura soit prêt
until curl -s http://hasura:8080/healthz > /dev/null; do
  echo "⏳ Attente de Hasura..."
  sleep 5
done

echo "✅ Hasura est prêt, démarrage de la surveillance des métadonnées..."

# Variables
LAST_METADATA_HASH=""
METADATA_FILE="/hasura-project/metadata/version.yaml"

while true; do
  # Calculer le hash des métadonnées actuelles
  if [ -f "$METADATA_FILE" ]; then
    CURRENT_HASH=$(find /hasura-project/metadata -type f -exec sha256sum {} \; | sha256sum | cut -d' ' -f1)
    
    if [ "$CURRENT_HASH" != "$LAST_METADATA_HASH" ] && [ -n "$LAST_METADATA_HASH" ]; then
      echo "🔄 Changement détecté dans les métadonnées Hasura"
      
      # Exporter les métadonnées
      echo "📤 Export des métadonnées..."
      /usr/local/bin/hasura metadata export --endpoint http://hasura:8080 --admin-secret myadminsecretkey
      
      # Générer une migration si nécessaire
      echo "🔧 Génération automatique de migration..."
      MIGRATION_NAME="auto_migration_$(date +%Y%m%d_%H%M%S)"
      /usr/local/bin/hasura migrate create "$MIGRATION_NAME" --from-server --endpoint http://hasura:8080 --admin-secret myadminsecretkey
      
      echo "✅ Migration générée: $MIGRATION_NAME"
      
      # Marquer le fichier pour Git
      touch /hasura-project/.hasura-changes
      echo "$(date): $MIGRATION_NAME" >> /hasura-project/.hasura-changes
    fi
    
    LAST_METADATA_HASH="$CURRENT_HASH"
  fi
  
  sleep 10
done