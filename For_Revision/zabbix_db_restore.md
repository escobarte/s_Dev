## 🛠️ Восстановление Zabbix Server после ошибки базы данных

### 🧪 1. Диагностика проблемы

```bash
# Проверить статус сервиса
systemctl status zabbix-server

# Проверить логи сервиса
journalctl -xeu zabbix-server.service
```

**Примеры ошибок:**

```
Can't open PID file /run/zabbix/zabbix_server.pid (yet?) after start: No such file or directory
Failed with result 'protocol'.
```

```bash
tail -n 50 /var/log/zabbix/zabbix_server.log
```

**Ошибки:**

```
cannot use database "zabbix": database is not a Zabbix database
[Z3005] query failed: [0] PGRES_FATAL_ERROR:ERROR:  relation "users" does not exist
```

### ✅ Вывод: база повреждена или не Zabbix — необходимо восстановление из дампа

---

### ⛔ Остановить сервер Zabbix на целевой машине

```bash
# На целевой машине (например, 10.100.93.7)
sudo systemctl stop zabbix-server
```

---

### 📥 2. Проверка и подготовка дампа на другом сервере (например, 10.100.93.8)

```bash
# Проверить наличие дампа от пользователя zabbixclidb
sudo -u zabbixclidb ls -lh /mnt/nfs/zabbix_client_db/
```

---

### 🧹 3. Удалить и пересоздать базу данных Zabbix

```bash
# Удалить старую базу
sudo -u postgres dropdb zabbix

# Создать новую с владельцем zabbix
sudo -u postgres createdb -O zabbix zabbix
```

---

### 📦 4. Войти под пользователем с правами доступа к NFS-директории

```bash
sudo -u zabbixclidb -i
```

---

### 🔄 5. Распаковать и восстановить дамп

```bash
gunzip -c /mnt/nfs/zabbix_client_db/zabbix_db_2025-07-22_08-56.sql.gz | psql -U zabbix -h 10.100.93.8 zabbix
```

---

### 🟢 6. Вернуться на основной сервер и запустить Zabbix

```bash
# Вернуться на 10.100.93.7
sudo systemctl start zabbix-server
```

Проверь логи, чтобы убедиться, что база подхватилась корректно:

```bash
journalctl -u zabbix-server -f
```
