# Flirit - Système de Gestion Automatisée

## 🚀 Fonctionnalités

### 🔄 Migrations Automatiques Hasura
- **Surveillance en temps réel** des changements depuis l'interface Hasura
- **Génération automatique** des migrations et export des métadonnées
- **Validation de sécurité** pour éviter les opérations dangereuses
- **Test d'intégrité** avant application en production

### 💾 Sauvegardes PostgreSQL Automatiques
- **Sauvegarde quotidienne** à 2h du matin avec rotation (7 jours)
- **Sauvegarde post-commit** après chaque commit Git
- **Compression automatique** des backups
- **Restauration facile** avec script dédié

### 🔐 Sécurité et Validation
- **Validation automatique** des migrations (détection des `DROP`, `TRUNCATE`, etc.)
- **Environnement de test** isolé pour tester les migrations
- **Hooks Git** pour bloquer les migrations dangereuses
- **CI/CD GitHub Actions** pour validation continue

## 📋 Installation

### 1. Configuration initiale

```bash
# Installation des hooks Git
chmod +x setup-hooks.sh
./setup-hooks.sh
```

### 2. Démarrage des services

```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

### 3. Accès aux interfaces

- **Hasura Console**: http://localhost:8080
- **PostgreSQL**: localhost:5432
- **Admin Secret**: `myadminsecretkey`

## 🛠️ Utilisation

### Migrations Automatiques

1. **Modifiez votre schéma** via l'interface Hasura (http://localhost:8080)
2. **Le système détecte automatiquement** les changements
3. **Les migrations sont générées** dans `hasura/migrations/`
4. **Lors du push Git**, les migrations sont validées et ajoutées automatiquement

### Sauvegardes

```bash
# Sauvegarde manuelle
docker-compose exec backup-cron /scripts/backup-db.sh

# Restauration
docker-compose exec backup-cron /scripts/restore-db.sh <backup_file.sql.gz>

# Lister les sauvegardes
ls -la backups/
```

### Test de Migration

```bash
# Tester une migration avant application
./scripts/test-migration.sh <migration_name> [backup_file]

# Exemple
./scripts/test-migration.sh 1751969848331_add-onboarding-step-to-profiles flirit_backup_20240101_120000.sql.gz
```

### Validation de Migration

```bash
# Valider une migration
./scripts/validate-migration.sh hasura/migrations/default/<migration_name>/up.sql
```

## 📁 Structure du Projet

```
flirit-docker/
├── docker-compose.yaml          # Configuration principale
├── hasura/                      # Configuration Hasura
│   ├── config.yaml
│   ├── metadata/               # Métadonnées exportées
│   └── migrations/             # Migrations générées
├── scripts/                    # Scripts d'automatisation
│   ├── watch-hasura.sh        # Surveillance des changements
│   ├── backup-db.sh           # Sauvegarde automatique
│   ├── restore-db.sh          # Restauration
│   ├── validate-migration.sh  # Validation sécurité
│   └── test-migration.sh      # Test isolé
├── backups/                   # Sauvegardes PostgreSQL
├── .githooks/                 # Hooks Git
│   ├── pre-push              # Validation avant push
│   └── post-commit           # Sauvegarde après commit
└── .github/workflows/         # CI/CD GitHub Actions
    └── hasura-ci.yml
```

## 🔧 Services Docker

- **postgres**: Base de données principale
- **hasura**: GraphQL Engine
- **hasura-cli**: Surveillance des changements
- **backup-cron**: Sauvegardes automatiques
- **postgres-test**: Environnement de test (profil `test`)

## ⚠️ Sécurité

### Opérations Bloquées
- `DROP TABLE` - Suppression de tables
- `TRUNCATE` - Vidage de tables
- `DELETE FROM ... WHERE 1=1` - Suppression massive
- `DROP COLUMN` - Suppression de colonnes

### Validation Multi-Niveaux
1. **Validation locale** (hooks Git)
2. **Test en environnement isolé**
3. **Validation CI/CD** (GitHub Actions)

## 🔍 Monitoring

```bash
# Logs des services
docker-compose logs -f hasura-cli    # Surveillance migrations
docker-compose logs -f backup-cron   # Sauvegardes

# Statut des sauvegardes
docker-compose exec backup-cron du -sh /backups

# Vérifier les migrations en attente
ls hasura/migrations/default/
```

## 🆘 Dépannage

### Problème de Migration
```bash
# Rollback manuel
docker-compose exec postgres psql -U postgres -d postgres -f /path/to/down.sql

# Test en environnement isolé
./scripts/test-migration.sh <migration_name>
```

### Problème de Sauvegarde
```bash
# Sauvegarde manuelle
docker-compose exec postgres pg_dump -U postgres postgres > backup_manual.sql
```

### Reset Complet
```bash
# ATTENTION: Supprime toutes les données
docker-compose down -v
docker-compose up -d
```

## 🚀 Workflow Recommandé

1. **Développement local**: Modifiez via Hasura Console
2. **Test automatique**: Le système génère et teste les migrations
3. **Validation**: Commit et push (validation automatique)
4. **Production**: Les migrations sont appliquées automatiquement
5. **Sauvegarde**: Backup automatique après chaque changement# perftrain-docker
