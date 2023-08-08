#!/usr/bin/with-contenv bashio

db=$1
EXT=$2

# This file could be customized to create custom delete strategy

while [ "$(find "$(bashio::config backup_folder)" -maxdepth 1 -name "*.$db.sql$EXT" -type f | wc -l)" -gt "$(bashio::config max_backups)" ]
do
  TARGET=$(find "$(bashio::config backup_folder)" -maxdepth 1 -name "*.$db.sql$EXT" -type f | sort | head -n 1)
  echo "==> Max number of ($MAX_BACKUPS) backups reached. Deleting ${TARGET} ..."
  rm -rf "${TARGET}"
  echo "==> Backup ${TARGET} deleted"
done