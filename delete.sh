#!/usr/bin/with-contenv bashio

db=$1
EXT=$2

# This file could be customized to create custom delete strategy
[ -z "$(bashio::config max_backups)" ] || { MAX_BACKUPS=$(bashio::config max_backups); }
[ -z "${MAX_BACKUPS}" ] && { MAX_BACKUPS=10; }

while [ "$(find "$(bashio::config backup_folder)" -maxdepth 1 -name "*.$db.sql$EXT" -type f | wc -l)" -gt "$MAX_BACKUPS" ]
do
  TARGET=$(find "$(bashio::config backup_folder)" -maxdepth 1 -name "*.$db.sql$EXT" -type f | sort | head -n 1)
  echo "==> Max number of ($MAX_BACKUPS) backups reached. Deleting ${TARGET} ..."
  rm -rf "${TARGET}"
  echo "==> Backup ${TARGET} deleted"
done