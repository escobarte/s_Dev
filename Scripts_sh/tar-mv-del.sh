!/bin/bash
#Decalaring
DIR_ETC="/etc/zabbix"
DIR_SHARE="/usr/share/zabbix"
DIR_LIB="/usr/lib/zabbix"
DIR_LOG="/var/log/zabbix/"

DATE=$(date +%F_%H-%M)

USERNFS="zabbixcli"
MOUNT="/mnt/nfs/zabbix_client"
LOGFILE="/var/log/zabbix_db_backup.log"

FILENAME_ETC="etc_zabbix_backup_${DATE}.tar.gz"
FILENAME_SHARE="share_zabbix_backup_${DATE}.tar.gz"
FILENAME_LIB="lib_zabbix_backup_${DATE}.tar.gz"
FILENAME_LOG="log_zabbix_backup_${DATE}.tar.gz"


#Logging
echo "................"
echo "................"
echo "................"
echo "................"
echo "[$(date)] ....Starting Backup  ......."
echo ".....................$DIR_ETC, $DIR_SHARE, $DIR_LIB...."
echo ".....................$DIR_LOG from Zabbix ............."
echo "................"
echo "................"
echo "................"
echo "................"
#Backuping
tar -czf - $DIR_ETC | sudo -u $USERNFS tee $MOUNT/$FILENAME_ETC > /dev/null
tar -czf - $DIR_SHARE | sudo -u $USERNFS tee $MOUNT/$FILENAME_SHARE > /dev/null
tar -czf - $DIR_LIB | sudo -u $USERNFS tee $MOUNT/$FILENAME_LIB > /dev/null
tar -czf - $DIR_LOG | sudo -u $USERNFS tee $MOUNT/$FILENAME_LOG > /dev/null

#Echo Result
if [[ $? -eq 0 ]]; then
        echo ".........Backup Successfully executed: ${DIR_ETC}" | tee -a "$LOGFILE"
        echo ".........Backup Successfully executed: ${DIR_SHARE}" | tee -a "$LOGFILE"
        echo ".........Backup Successfully executed: ${DIR_LIB}" | tee -a "$LOGFILE"
        echo ".........Backup Successfully executed: ${DIR_LOG}" | tee -a "$LOGFILE"
else
        echo "[$(date)] FAILED .... Read from $LOGFILE" | tee -a "$LOGFILE"
fi

#echo "Deleting old files if exist"
#sudo -u "$USERNFS" find "$MOUNT" -maxdepth 1 -type f \
#    \( -name "etc_zabbix_backup_*.tar.gz" -o \
#       -name "share_zabbix_backup_*.tar.gz" -o \
#       -name "lib_zabbix_backup_*.tar.gz" -o \
#       -name "log_zabbix_backup_*.tar.gz" -o \
#       -name "zabbix_db_*.sql.gz" \) \
#    -mmin +1 -delete

echo "Deleting old files if exist:"
sudo -u "$USERNFS" find "$MOUNT" -maxdepth 15 -type f \
    \( -name "etc_zabbix_backup_*.tar.gz" -o \
       -name "share_zabbix_backup_*.tar.gz" -o \
       -name "lib_zabbix_backup_*.tar.gz" -o \
       -name "log_zabbix_backup_*.tar.gz" -o \
       -name "zabbix_db_*.sql.gz" \) \
    -mtime +5 -print0 | xargs -0 -r sudo -u "$USERNFS" rm -v | tee -a "$LOGFILE"