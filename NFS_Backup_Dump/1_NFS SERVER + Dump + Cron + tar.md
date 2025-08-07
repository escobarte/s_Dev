# Настройка резервного копирования Zabbix через NFS и LVM

## 1. Просмотр информации о дисках и разделах

```bash
lsblk                            # Показать все блочные устройства
lsblk -f /dev/sdb                # Подробная информация о /dev/sdb
fdisk -l /dev/sdb                # Разметка и разделы диска /dev/sdb
parted /dev/sdb unit GB print free   # Свободное место на диске в GB
du -sh /srv/nfs                  # Размер директории NFS
```

## 2. Настройка LVM и монтирование для NFS

- Перенастроить LVM (см. отдельный блокнот по LVM).
- Смонтировать том на `/srv/nfs/`.

## 3. Настройка NFS-сервера на `93.5`

```bash
apt update
apt install nfs-kernel-server -y              # Установка NFS сервера
systemctl status nfs-server                   # Проверка статуса

mkdir -p /srv/nfs/zabbix_backup               # Директория под бэкапы
chown root:root /srv/nfs/zabbix_backup        # Владелец root (лучше сменить на пользователя zabbixsrv)
chmod 777 /srv/nfs/zabbix_backup              # Временно полный доступ (потом ограничить)
```

**Важно!** После теста заменить права и владельца на пользователя только для Zabbix.

**Настройка экспорта:**

```bash
echo '/srv/nfs/zabbix_backup 10.100.93.7(rw,sync,no_subtree_check,fsid=0,root_squash)' | tee -a /etc/exports
exportfs -ra                                  # Применить изменения экспорта
exportfs -v                                   # Проверить экспортированные каталоги
```

### 3.1 Настройка портов и IPTABLES для NFS

```bash
nano /etc/nfs.conf
# [nfsd]    port=2049
# [mountd]  port=32767
# [statd]   port=32765
# [lockd]   port=32766

systemctl restart nfs-server
```

**Разрешение только с нужного клиента:**

```bash
# TCP/UDP 2049 — nfsd, TCP 111 — rpcbind, TCP 32765–32769 — mountd, statd, lockd
iptables -A INPUT -s 10.100.93.7 -p tcp -m multiport --dports 111,2049,32765:32769 -j ACCEPT
iptables -A INPUT -s 10.100.93.7 -p udp -m multiport --dports 111,2049,32765:32769 -j ACCEPT

# Запретить остальным
iptables -A INPUT -p tcp -m multiport --dports 111,2049,32765:32769 -j DROP
iptables -A INPUT -p udp -m multiport --dports 111,2049,32765:32769 -j DROP

# Сохраняем правила (Ubuntu)
apt install iptables-persistent -y
netfilter-persistent save
```

## 4. Установка NFS-клиента на `93.8` и `93.7`

```bash
apt update && apt install nfs-common -y        # Установка клиента NFS
mkdir -p /mnt/nfs/zabbix_client                # Каталог монтирования
mount 10.100.93.5:/srv/nfs/zabbix_backup /mnt/nfs/zabbix_client
df -h | grep nfs                               # Проверка монтирования
touch /mnt/nfs/zabbix_client/file_to_test      # Проверка записи
sudo -u zabbix touch /mnt/nfs/zabbix_client/test.file
```

## 5. Создание пользователей для синхронизации прав

**На сервере:**

```bash
getent passwd | cut -d: -f3 | sort -n | tail  # Проверить, свободен ли UID 1050
useradd -u 1050 -m -s /bin/bash zabbixsrv     # Создать пользователя с нужным UID

# Если ошибка - переименовать или удалить старого пользователя:
cut -d: -f1 /etc/passwd | grep zabb
usermod -l error_name new_name                # Переименование пользователя
userdel zabbixsrv                             # Удалить пользователя
grep "zabb" /etc/group                        # Проверить группы

chown zabbixsrv:zabbixsrv /srv/nfs/zabbix_backup    # Назначить владельца каталога
chmod 750 /srv/nfs/zabbix_backup/                   # Ограничить права
ls -ld /srv/nfs/zabbix_backup/
id zabbixsrv                                      # Проверка ID пользователя
```

**На клиенте:**

```bash
useradd -u 1050 -m -s /bin/bash zabbixcli      # Создать пользователя с тем же UID
id zabbixcli                                   # Проверка ID

mount 10.100.93.5:/srv/nfs/zabbix_backup /mnt/nfs/zabbix_client/

# Проверка записи от имени пользователя
sudo -u zabbixcli touch /mnt/nfs/zabbix_client/test.file
sudo -u zabbixcli bash -c 'echo "backup" > /mnt/nfs/zabbix_client/test.log'
```

---

## Архитектура

| Роль                | Сервер | Директории/Описание                            |
| ------------------- | ------ | ---------------------------------------------- |
| БД PostgreSQL       | 93.8   | zabbix                                         |
| Конфиги, веб Zabbix | 93.7   | /etc/zabbix, /usr/share/zabbix и др.           |
| Хранилище NFS       | 93.5   | /srv/nfs/zabbix_backup (монтируется клиентами) |

---

## 6. Ручной дамп БД Zabbix (`93.8 → NFS`)

```bash
# Дамп и сразу копия в NFS через пользователя с тем же UID:
sudo -u zabbix pg_dump zabbix | gzip | sudo -u zabbixclidb tee /mnt/nfs/zabbix_client_db/zabbix_db_$(date +%F_%H-%M).sql.gz > /dev/null

# Проверка результата:
sudo -u zabbixclidb ls -la /mnt/nfs/zabbix_client_db/
```

---

## 7. Скрипт для регулярного бэкапа БД (`/opt/dump_db_zabbix.sh`, сервер 93.8)

```bash
#!/bin/bash

# Переменные
USERNFS="zabbixclidb"                         # Пользователь для доступа к NFS
DATE=$(date +%F_%H-%M)
LOGFILE="/var/log/zabbix_db_backup.log"
FILENAME="zabbix_db_${DATE}.sql.gz"
BACKUP_DIR="/mnt/nfs/zabbix_client_db"

echo "[$(date)] Starting Backup Database Zabbix ...." | tee -a "$LOGFILE"

# Дамп БД и gzip, сразу записываем в NFS как нужный пользователь
sudo -u zabbix pg_dump zabbix | gzip | sudo -u $USERNFS tee $BACKUP_DIR/$FILENAME > /dev/null

# Проверка результата выполнения
if [[ $? -eq 0 ]]; then
    echo "[$(date)] Dump, GZIP and MV on 93.5 successful: ${FILENAME}" | tee -a "$LOGFILE"
else
    echo "[$(date)] FAILED ...." | tee -a "$LOGFILE"
fi

# Удаление файлов старше 20 минут (можно изменить на 60 для часа)
echo "[$(date)] Verifying and Delete files 20m older ...." | tee -a "$LOGFILE"
sudo -u $USERNFS find "$BACKUP_DIR" -maxdepth 1 -type f -name "zabbix_db_*.sql.gz" -mmin +20 -print0 | xargs -0 -r sudo -u "$USERNFS" rm -v | tee -a "$LOGFILE"
```

---

## 8. Настройка Cron для автозапуска бэкапов

```bash
crontab -e

# Ежедневный дамп базы в 8:55
55 8 * * * /opt/dump_db_zabbix.sh

# Ежедневно backup файлов конфигов (см. ниже)
55 8 * * * /opt/tar-mv-del.sh
```

---

## 9. Скрипт для резервного копирования конфигов и логов Zabbix (`/opt/tar-mv-del.sh`, сервер 93.7)

```bash
#!/bin/bash

# Каталоги для резервного копирования
DIR_ETC="/etc/zabbix"
DIR_SHARE="/usr/share/zabbix"
DIR_LIB="/usr/lib/zabbix"
DIR_LOG="/var/log/zabbix/"
DATE=$(date +%F_%H-%M)

USERNFS="zabbixcli"           # Пользователь для записи в NFS
MOUNT="/mnt/nfs/zabbix_client"
LOGFILE="/var/log/zabbix_db_backup.log"

FILENAME_ETC="etc_zabbix_backup_${DATE}.tar.gz"
FILENAME_SHARE="share_zabbix_backup_${DATE}.tar.gz"
FILENAME_LIB="lib_zabbix_backup_${DATE}.tar.gz"
FILENAME_LOG="log_zabbix_backup_${DATE}.tar.gz"

# Логирование
echo "[$(date)] Starting Backup ..." | tee -a "$LOGFILE"

# Резервное копирование с отправкой напрямую на NFS
tar -czf - $DIR_ETC   | sudo -u $USERNFS tee $MOUNT/$FILENAME_ETC > /dev/null
tar -czf - $DIR_SHARE | sudo -u $USERNFS tee $MOUNT/$FILENAME_SHARE > /dev/null
tar -czf - $DIR_LIB   | sudo -u $USERNFS tee $MOUNT/$FILENAME_LIB > /dev/null
tar -czf - $DIR_LOG   | sudo -u $USERNFS tee $MOUNT/$FILENAME_LOG > /dev/null

# Проверка выполнения
if [[ $? -eq 0 ]]; then
    echo "Backup Successfully executed" | tee -a "$LOGFILE"
else
    echo "[$(date)] FAILED .... Read from $LOGFILE" | tee -a "$LOGFILE"
fi

# Удаление старых файлов (старше 1 часа, можно изменить на -mmin +60)
echo "Deleting old files if exist:"
sudo -u "$USERNFS" find "$MOUNT" -maxdepth 1 -type f \
    \( -name "etc_zabbix_backup_*.tar.gz" -o \
       -name "share_zabbix_backup_*.tar.gz" -o \
       -name "lib_zabbix_backup_*.tar.gz" -o \
       -name "log_zabbix_backup_*.tar.gz" -o \
       -name "zabbix_db_*.sql.gz" \) \
    -mmin +60 -delete
```

---

## 10. Проверка наличия файлов бэкапа

```bash
# Проверить бэкапы на стороне NFS (как соответствующий пользователь):
sudo -u zabbixclidb ls -lh /mnt/nfs/zabbix_client_db/
sudo -u zabbixcli ls -lh /mnt/nfs/zabbix_client/
```
