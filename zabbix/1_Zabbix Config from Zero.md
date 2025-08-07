# Установка Zabbix Server с базой PostgreSQL

## Сервер Zabbix (`10.100.93.7`)

### 1. Добавление репозитория Zabbix
```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
sudo apt update
```

### 2. Установка необходимых пакетов
```bash
sudo apt install zabbix-server-pgsql zabbix-frontend-php php-pgsql \
zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y
```

### 3. Настройка подключения к базе данных
```bash
sudo nano /etc/zabbix/zabbix_server.conf
```

Изменить или добавить параметры:
```
DBHost=10.100.93.8
DBName=zabbix
DBUser=zabbix
DBPassword=1323
```

### 4. Запуск и автозапуск сервиса Zabbix
```bash
sudo systemctl enable zabbix-server
sudo systemctl start zabbix-server
sudo systemctl status zabbix-server
```

---

## Сервер PostgreSQL (`10.100.93.8`)

### 1. Установка PostgreSQL 16
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl status postgresql
```

### 2. Создание базы и пользователя
```bash
sudo -u postgres psql
```

Внутри `psql`:
```sql
CREATE DATABASE zabbix;
CREATE USER zabbix WITH ENCRYPTED PASSWORD '1323';
GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;
GRANT ALL ON SCHEMA public TO zabbix;
ALTER SCHEMA public OWNER TO zabbix;
\q
```

Если база уже была и вы её удалили:
```bash
sudo -u postgres dropdb zabbix
```
Затем снова:
```bash
sudo -u postgres psql
CREATE DATABASE zabbix OWNER zabbix;
GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;
GRANT ALL ON SCHEMA public TO zabbix;
ALTER SCHEMA public OWNER TO zabbix;
\q
```

### 3. Настройка доступа PostgreSQL
```bash
sudo nano /etc/postgresql/16/main/pg_hba.conf
```

Добавить в конец:
```
host    zabbix    zabbix    10.100.93.7/32    md5
```

Открыть доступ на все адреса:
```bash
sudo nano /etc/postgresql/16/main/postgresql.conf
```

Найти строку:
```
#listen_addresses = 'localhost'
```
Заменить на:
```
listen_addresses = '*'
```

Перезапустить PostgreSQL:
```bash
sudo systemctl restart postgresql
```

---

## Импорт базы данных Zabbix (на `93.7`)
```bash
sudo apt install postgresql-client -y
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | \
psql -h 10.100.93.8 -U zabbix zabbix
```
