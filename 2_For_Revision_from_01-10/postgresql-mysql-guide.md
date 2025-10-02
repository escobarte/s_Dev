# PostgreSQL & MySQL Quick Reference Guide

## 📌 Key Definitions

**PostgreSQL** - Open-source relational database known for reliability and advanced features  
**MySQL** - Popular open-source database, fast and widely supported  
**psql** - PostgreSQL command-line interface  
**mysql** - MySQL command-line interface  
**SERIAL** - PostgreSQL auto-increment type  
**AUTO_INCREMENT** - MySQL auto-increment attribute  

---

## 🚀 Installation Commands

### PostgreSQL on Ubuntu
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
```

### MySQL on Ubuntu
```bash
sudo apt update
sudo apt install mysql-server -y
sudo mysql_secure_installation  # Run security setup
```

---

## 🔑 Database Access

### PostgreSQL Login
```bash
sudo -u postgres psql              # Default admin access
psql -U username -d database_name  # Specific user/database
```

### MySQL Login
```bash
sudo mysql                         # Root without password
mysql -u root -p                   # Root with password
mysql -u username -p database_name # Specific user/database
```

---

## 📊 Essential Console Commands

| Action | PostgreSQL | MySQL |
|--------|------------|-------|
| **List databases** | `\l` | `SHOW DATABASES;` |
| **Switch database** | `\c dbname` | `USE dbname;` |
| **List tables** | `\dt` | `SHOW TABLES;` |
| **Table structure** | `\d tablename` | `DESCRIBE tablename;` |
| **List users** | `\du` | `SELECT User FROM mysql.user;` |
| **Help** | `\?` | `HELP;` |
| **Exit** | `\q` | `exit;` or `quit;` |

---

## 💾 Database & User Management

### PostgreSQL
```sql
-- Create database
CREATE DATABASE testdb;

-- Create user with password
CREATE USER testuser WITH PASSWORD 'password123';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;
```

### MySQL
```sql
-- Create database
CREATE DATABASE testdb;

-- Create user with password
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'password123';

-- Grant privileges
GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';
FLUSH PRIVILEGES;
```

---

## 📝 Table Operations

### Create Table - PostgreSQL
```sql
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT CURRENT_DATE
);
```

### Create Table - MySQL
```sql
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT (CURRENT_DATE)
);
```

---

## 🔍 Basic SQL Operations

### INSERT Data
```sql
INSERT INTO employees (name, email, salary) 
VALUES ('John Doe', 'john@example.com', 75000);
```

### SELECT Data
```sql
SELECT * FROM employees WHERE salary > 50000;
SELECT name, salary FROM employees ORDER BY salary DESC;
SELECT department, AVG(salary) FROM employees GROUP BY department;
```

### UPDATE Data
```sql
UPDATE employees SET salary = salary * 1.1 WHERE department = 'IT';
```

### DELETE Data
```sql
DELETE FROM employees WHERE id = 1;
```

---

## 🛠️ Backup & Restore

### PostgreSQL
```bash
# Backup
pg_dump -U postgres -d dbname > backup.sql

# Restore
psql -U postgres -d dbname < backup.sql
```

### MySQL
```bash
# Backup
mysqldump -u root -p dbname > backup.sql

# Restore
mysql -u root -p dbname < backup.sql
```

---

## 🌐 Enable Remote Access

### PostgreSQL
1. Edit `/etc/postgresql/[version]/main/postgresql.conf`:
   ```
   listen_addresses = '*'
   ```

2. Edit `/etc/postgresql/[version]/main/pg_hba.conf`:
   ```
   host    all    all    0.0.0.0/0    md5
   ```

3. Restart: `sudo systemctl restart postgresql`

### MySQL
1. Edit `/etc/mysql/mysql.conf.d/mysqld.cnf`:
   ```
   bind-address = 0.0.0.0
   ```

2. Create remote user:
   ```sql
   CREATE USER 'user'@'%' IDENTIFIED BY 'password';
   GRANT ALL PRIVILEGES ON *.* TO 'user'@'%';
   ```

3. Restart: `sudo systemctl restart mysql`

---

## 🔧 Troubleshooting Tips

### PostgreSQL
- **Can't connect:** Check if service is running: `sudo systemctl status postgresql`
- **Permission denied:** Use `sudo -u postgres psql` for initial access
- **Port issues:** Default port is 5432

### MySQL
- **Access denied:** Use `sudo mysql` for initial root access
- **Password issues:** Run `sudo mysql_secure_installation` to reset
- **Port issues:** Default port is 3306

---

## 📚 Key Differences

| Feature | PostgreSQL | MySQL |
|---------|------------|-------|
| **Default admin** | postgres user | root user |
| **Auth method** | peer authentication | auth_socket or password |
| **Auto-increment** | SERIAL | AUTO_INCREMENT |
| **Database switch** | `\c` command | `USE` statement |
| **Case sensitivity** | Case-sensitive | Case-insensitive on Windows |
| **Full-text search** | Built-in | Limited support |

---

## 🎯 Best Practices

1. **Always use strong passwords** for database users
2. **Regular backups** - automate daily backups
3. **Limit user privileges** - grant only necessary permissions
4. **Keep software updated** - apply security patches
5. **Use SSL/TLS** for remote connections
6. **Monitor logs** - check `/var/log/postgresql/` or `/var/log/mysql/`
7. **Use indexes** for frequently queried columns
8. **Avoid storing passwords** in command history

---

## 📖 Quick Command Reference Card

```bash
# PostgreSQL Quick Access
sudo -u postgres psql
\l                    # list databases
\c dbname            # connect to database
\dt                  # show tables
\q                   # quit

# MySQL Quick Access  
sudo mysql
SHOW DATABASES;      # list databases
USE dbname;          # select database
SHOW TABLES;         # show tables
exit;                # quit
```

---

*Generated: PostgreSQL & MySQL Essential Guide - Ready for practice and reference*