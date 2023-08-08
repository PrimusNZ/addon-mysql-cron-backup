#!/usr/bin/with-contenv bashio

# Get hostname: try read from file, else get from env
[ -z "$(bashio::config mysql_host)" ] || { MYSQL_HOST=$(bashio::config mysql_host); }
[ -z "${MYSQL_HOST}" ] && { echo "=> MYSQL_HOST cannot be empty" && exit 1; }
# Get username: try read from file, else get from env
[ -z "$(bashio::config mysql_user)" ] || { MYSQL_USER=$(bashio::config mysql_user); }
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
# Get password: try read from file, else get from env, else get from MYSQL_PASSWORD env
[ -z "$(bashio::config mysql_pass)" ] || { MYSQL_PASS=$(bashio::config mysql_pass); }
[ -z "${MYSQL_PASS}" ] && { echo "=> MYSQL_PASS cannot be empty" && exit 1; }
# Get database name(s): try read from file, else get from env
# Note: when from file, there can be one database name per line in that file
[ -z "$(bashio::config mysql_db)" ] || { MYSQL_DATABASE=$(bashio::config mysql_db); }
[ -z "${MYSQL_DATABASE}" ] && { echo "=> MYSQL_DATABASE cannot be empty" && exit 1; }

[ -z "$(bashio::config mysql_port)" ] || { MYSQL_PORT=$(bashio::config mysql_port); }
[ -z "${MYSQL_PORT}" ] && { MYSQL_PORT=3306; }

[ -z "$(bashio::config mysql_ssl_opts)" ] || { MYSQL_SSL_OPTS=$(bashio::config mysql_ssl_opts); }
[ -z "${MYSQL_SSL_OPTS}" ] && { MYSQL_SSL_OPTS=""; }

[ -z "$(bashio::config mysqldump_opts)" ] || { MYSQL_DUMP_OPTS=$(bashio::config mysqldump_opts); }
[ -z "${MYSQL_DUMP_OPTS}" ] && { MYSQL_DUMP_OPTS=""; }

# Get level from env, else use 6
[ -z "$(bashio::config gzip_level)" ] && { GZIP_LEVEL=6; }

DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"
DATABASES=${MYSQL_DATABASE:-${MYSQL_DB:-$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" $MYSQL_SSL_OPTS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)}}
for db in ${DATABASES}
do
  if  [[ "$db" != "information_schema" ]] \
      && [[ "$db" != "performance_schema" ]] \
      && [[ "$db" != "mysql" ]] \
      && [[ "$db" != "sys" ]] \
      && [[ "$db" != _* ]]
  then
    echo "==> Dumping database: $db"
    FILENAME="$(bashio::config backup_folder)/$DATE.$db.sql"
    LATEST="$(bashio::config backup_folder)/latest.$db.sql"
    if mysqldump --single-transaction $MYSQL_DUMP_OPTS -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" $MYSQL_SSL_OPTS "$db" > "$FILENAME"
    then
      EXT=
      if [ -z "${USE_PLAIN_SQL}" ]
      then
        echo "==> Compressing $db with LEVEL $GZIP_LEVEL"
        gzip "-$GZIP_LEVEL" -f "$FILENAME"
        EXT=.gz
        FILENAME=$FILENAME$EXT
        LATEST=$LATEST$EXT
      fi
      BASENAME=$(basename "$FILENAME")
      echo "==> Creating symlink to latest backup: $BASENAME"
      rm "$LATEST" 2> /dev/null
      cd "$(bashio::config backup_folder)" || exit && ln -s "$BASENAME" "$(basename "$LATEST")"
      if [ -n "$MAX_BACKUPS" ]
      then
        # Execute the delete script, delete older backup or other custom delete script
        /delete.sh "$db" $EXT
      fi
    else
      rm -rf "$FILENAME"
    fi
  fi
done
echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"
