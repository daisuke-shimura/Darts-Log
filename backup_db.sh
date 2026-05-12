APP_DIR="/home/daisuke/environment/Darts-Log"
DB_FILE="$APP_DIR/db/production.sqlite3"

BACKUP_FILE="/mnt/c/Users/daisu/Dropbox/darts_backup/production_backup.sqlite3"

sqlite3 "$DB_FILE" ".backup $BACKUP_FILE"
