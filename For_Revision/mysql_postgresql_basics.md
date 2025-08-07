## 🗃️ Базовые команды MySQL и PostgreSQL для администрирования

---

## 🐬 MySQL

### 📦 Работа с базами данных

```sql
-- Создать базу данных с поддержкой Unicode
CREATE DATABASE laravel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Удалить базу данных
DROP DATABASE database_name;

-- Показать все базы данных
SHOW DATABASES;

-- Использовать конкретную базу данных
USE laravel;
```

---

### 👤 Работа с пользователями

```sql
-- Показать пользователей и хосты
SELECT User, Host FROM mysql.user;

-- Создать пользователя (например, для 10.100.93.4)
CREATE USER 'laravel_user_app04'@'10.100.93.4' IDENTIFIED BY '1323';

-- Выдать все привилегии на базу laravel
GRANT ALL PRIVILEGES ON laravel.* TO 'laravel_user_app04'@'10.100.93.4';

-- Применить изменения
FLUSH PRIVILEGES;

-- Удалить пользователя
DROP USER 'username'@'host';

-- Выйти из mysql
EXIT;
```

---

### ✅ Проверка подключения к MySQL с другого сервера (например, 93.4)

```bash
sudo apt install mysql-client -y
mysql -h 10.100.93.8 -u laravel_user_app04 -p
```

---

## 🐘 PostgreSQL

### 📦 Работа с базами и пользователями

```sql
-- Показать базы данных (исключая шаблоны)
SELECT datname FROM pg_database WHERE datistemplate = false;

-- Показать всех пользователей
SELECT usename FROM pg_user;
```

---

### 🛠️ Изменение владельца схемы

```sql
ALTER SCHEMA public OWNER TO postgres;
```
