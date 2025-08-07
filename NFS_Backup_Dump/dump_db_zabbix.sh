#!/bin/bash

#Variables & Config
USERNFS="zabbixclidb"
DATE=$(date +%F_%H-%M)
LOGFILE="/var/log/zabbix_db_backup.log"
FILENAME="zabbix_db_${DATE}.sql.gz"
BACKUP_DIR="/mnt/nfs/zabbix_client_db"

#Logging
echo "[$(date)] Starting Backup Database Zabbix ...." | tee -a "$LOGFILE"

#Dump
sudo -u zabbix pg_dump zabbix | gzip | sudo -u $USERNFS tee /mnt/nfs/zabbix_client_db/$FILENAME > /dev/null

#Echo Result
if [[ $? -eq 0 ]]; then
        echo "[$(date)] Dump, GZIP and MV on 93.5 successful: ${FILENAME}" | tee -a "$LOGFILE"
else
        echo "[$(date)] FAILED ...." | tee -a "$LOGFILE"
fi

#Clean 5 Days max
echo "[$(date)] Verifying and Delete files 5 Days older ...." | tee -a "$LOGFILE"
sudo -u $USERNFS find "$BACKUP_DIR" -maxdepth 1 -type f -name "zabbix_db_*.sql.gz" -mtime +5 -print0 | xargs -0 -r sudo -u "$USERNFS" rm -v | tee -a "$LOGFILE"