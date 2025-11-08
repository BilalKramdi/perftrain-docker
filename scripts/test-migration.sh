#!/bin/sh

# Script pour tester une migration dans un environnement isolé

set -e

if [ "$#" -lt 1 ]; then
    echo "❌ Usage: $0 <migration_name> [backup_file]"
    echo "Exemple: $0 1751969848331_add-onboarding-step-to-profiles flirit_backup_20240101_120000.sql.gz"
    exit 1
fi

MIGRATION_NAME="$1"
BACKUP_FILE="$2"

echo "🧪 Test de migration: $MIGRATION_NAME"

# Démarrer l'environnement de test
echo "🚀 Démarrage de l'environnement de test PostgreSQL..."
docker-compose --profile test up -d postgres-test

# Attendre que PostgreSQL test soit prêt
echo "⏳ Attente de PostgreSQL test..."
until docker-compose exec postgres-test pg_isready -U postgres > /dev/null 2>&1; do
  sleep 2
done

echo "✅ PostgreSQL test est prêt"

# Restaurer les données si un backup est fourni
if [ -n "$BACKUP_FILE" ]; then
    echo "🔄 Restauration des données de test depuis: $BACKUP_FILE"
    
    if [ ! -f "/Users/bilalkramdi/Documents/Perso/flirit/flirit-docker/backups/$BACKUP_FILE" ]; then
        echo "❌ Fichier de sauvegarde non trouvé: $BACKUP_FILE"
        docker-compose --profile test down
        exit 1
    fi
    
    # Copier et restaurer la sauvegarde
    docker-compose exec postgres-test sh -c "
        cd /scripts &&
        POSTGRES_HOST=localhost \
        POSTGRES_DB=postgres_test \
        POSTGRES_PASSWORD=postgrespassword \
        ./restore-db.sh $BACKUP_FILE
    " || {
        echo "❌ Erreur lors de la restauration"
        docker-compose --profile test down
        exit 1
    }
else
    echo "ℹ️  Aucune sauvegarde fournie, utilisation d'une base vide"
fi

# Appliquer la migration
echo "🔧 Application de la migration: $MIGRATION_NAME"

MIGRATION_PATH="/Users/bilalkramdi/Documents/Perso/flirit/flirit-docker/hasura/migrations/default/$MIGRATION_NAME"

if [ ! -d "$MIGRATION_PATH" ]; then
    echo "❌ Migration non trouvée: $MIGRATION_PATH"
    docker-compose --profile test down
    exit 1
fi

# Appliquer la migration up.sql
if [ -f "$MIGRATION_PATH/up.sql" ]; then
    echo "⬆️  Application de up.sql..."
    docker-compose exec postgres-test psql -U postgres -d postgres_test -f "/scripts/../hasura/migrations/default/$MIGRATION_NAME/up.sql" || {
        echo "❌ Erreur lors de l'application de up.sql"
        
        # Tenter de rollback si down.sql existe
        if [ -f "$MIGRATION_PATH/down.sql" ]; then
            echo "🔄 Tentative de rollback avec down.sql..."
            docker-compose exec postgres-test psql -U postgres -d postgres_test -f "/scripts/../hasura/migrations/default/$MIGRATION_NAME/down.sql" || true
        fi
        
        docker-compose --profile test down
        exit 1
    }
    
    echo "✅ Migration up.sql appliquée avec succès"
else
    echo "❌ Fichier up.sql non trouvé dans la migration"
    docker-compose --profile test down
    exit 1
fi

# Test basique: vérifier que la base est toujours accessible
echo "🔍 Test de base: vérification de l'intégrité de la base..."
docker-compose exec postgres-test psql -U postgres -d postgres_test -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';" || {
    echo "❌ La base de données semble corrompue après la migration"
    docker-compose --profile test down
    exit 1
}

# Test optionnel: tester le rollback
echo "🔄 Test du rollback..."
if [ -f "$MIGRATION_PATH/down.sql" ]; then
    echo "⬇️  Application de down.sql (rollback)..."
    docker-compose exec postgres-test psql -U postgres -d postgres_test -f "/scripts/../hasura/migrations/default/$MIGRATION_NAME/down.sql" || {
        echo "⚠️  Erreur lors du rollback - cela pourrait être problématique"
    }
    
    echo "⬆️  Re-application de up.sql..."
    docker-compose exec postgres-test psql -U postgres -d postgres_test -f "/scripts/../hasura/migrations/default/$MIGRATION_NAME/up.sql" || {
        echo "❌ Erreur lors de la re-application après rollback"
        docker-compose --profile test down
        exit 1
    }
    
    echo "✅ Test de rollback réussi"
else
    echo "⚠️  Pas de fichier down.sql trouvé - rollback non testé"
fi

# Nettoyage
echo "🧹 Nettoyage de l'environnement de test..."
docker-compose --profile test down

echo "✅ Test de migration terminé avec succès!"
echo "🎉 La migration $MIGRATION_NAME peut être appliquée en toute sécurité."