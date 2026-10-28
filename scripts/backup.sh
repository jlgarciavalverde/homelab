#!/usr/bin/env bash
# backup.sh — copia local de los servicios del VPS (compra + Nextcloud).
# Las copias viven en ~/backups/<fecha>/ con retención de KEEP últimas.
# OJO: son copias locales (mismo disco). Protegen contra borrados/corrupción,
# NO contra fallo del disco. El off-site se decidirá aparte.
set -euo pipefail

SERVICIOS="$HOME/servicios"
DEST_ROOT="$HOME/backups"
KEEP=8
STAMP="$(date +%F_%H%M)"
DEST="$DEST_ROOT/$STAMP"
mkdir -p "$DEST"

log() { echo "[$(date +%T)] $*"; }

# --- Credenciales de la BD de Nextcloud ---
set -a
# shellcheck disable=SC1091
source "$SERVICIOS/nextcloud/.env"
set +a

maintenance() { # on|off
  docker exec -u www-data nextcloud php occ maintenance:mode --"$1" >/dev/null
}

log "Inicio backup $STAMP"

# 1) Dump de la base de datos de Nextcloud
log "Dump MariaDB (nextcloud)..."
docker exec nextcloud-db-1 mariadb-dump -u nextcloud -p"$DB_PASSWORD" --single-transaction nextcloud \
  | gzip > "$DEST/nextcloud-db.sql.gz"

# 2) Datos de Nextcloud (volumen) con maintenance:mode para consistencia
log "Copia volumen nextcloud (maintenance on)..."
maintenance on
trap 'maintenance off' EXIT
docker exec nextcloud tar czf - -C /var/www/html . > "$DEST/nextcloud-data.tar.gz"
maintenance off
trap - EXIT
log "maintenance off"

# 3) Datos de compra (BD sqlite + dumps internos)
log "Copia datos de compra..."
tar czf "$DEST/compra-data.tar.gz" -C "$SERVICIOS/compra" data

# 4) Manifiesto con tamaños
{
  echo "# Backup $STAMP"
  echo "# hostname: $(hostname)  user: $(whoami)"
  du -sh "$DEST"/*
} > "$DEST/MANIFEST.txt"

# 5) Retención: borrar las más antiguas quedándonos con las $KEEP últimas
log "Aplicando retención (mantener $KEEP)..."
cd "$DEST_ROOT"
ls -1d 2* | sort | head -n -"$KEEP" | while read -r old; do
  log "  eliminando $old"
  rm -rf -- "$old"
done

log "Fin backup. Total: $(du -sh "$DEST" | cut -f1)"
