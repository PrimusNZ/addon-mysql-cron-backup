#!/bin/bash
tail -F /mysql_backup.log &

touch /HEALTHY.status

if [ ! -d "$(bashio::config backup_folder)" ]; then
  echo "=> Backups folder $(bashio::config backup_folder) doesnt exist. Creating..."
  mkdir -p "$(bashio::config backup_folder)"
fi

echo "=> Backing up to $(bashio::config backup_folder)"
echo "$(bashio::config cron_time) /backup.sh >> /mysql_backup.log 2>&1" > /tmp/crontab.conf
crontab /tmp/crontab.conf
echo "=> Running cron task manager in foreground"
crond -f -l 8 -L /mysql_backup.log &

echo "Listening on crond, and wait..."

tail -f /dev/null & wait $!

echo "Script is shutted down."