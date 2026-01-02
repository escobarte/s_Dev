# Git Deployment & Database Migration Guide

## Ticket #99305 - particip.gov.md Update

---

## 1. Pre-Deployment Checklist

### 1.1 Create Snapshots
**Why:** Safety rollback point in case of failure
```bash
# Create VM snapshot before any changes
```

### 1.2 Database Backup
**Critical:** Always backup before migrations

```bash
# Navigate to backups directory
cd /DATA/participadmin.gov.md/backups

# Create PostgreSQL dump
pg_dump -U participadmin -h localhost participadmin > dump_participadmin_$(date +%Y%m%d_%H%M%S).sql

# Or compressed version (recommended)
pg_dump -U participadmin -h localhost participadmin | gzip > dump_participadmin_$(date +%Y%m%d_%H%M%S).sql.gz
```

**Database credentials:**
- Host: `localhost`
- Database: `participadmin`
- Username: `participadmin`
- Connection: `pgsql`

---

## 2. Git Operations

### 2.1 Check Current Status
```bash
cd /DATA/participadmin.gov.md/htdocs
git status
git remote -v
```

### 2.2 Add Remote Repository (if needed)
```bash
git remote add origin https://git.itsec.md/cs/particip/admin-particip.git
```

### 2.3 Fetch Changes (without applying)
**What it does:** Downloads changes from server but doesn't apply them
```bash
git fetch origin
```

### 2.4 View Available Updates
```bash
# See what changed
git log HEAD..origin/test --oneline

# See file differences
git diff HEAD origin/test

# See modified files
git diff --name-only HEAD origin/test
```

### 2.5 Apply Updates
```bash
git pull origin test
```

---

## 3. Laravel Deployment Steps

### 3.1 Update Dependencies
```bash
composer install --no-dev --optimize-autoloader
```

### 3.2 Run Database Migrations
```bash
php artisan migrate
```

### 3.3 Clear Caches
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

---

## 4. Permission Management

### 4.1 Key Concepts

**System Users:**
- `root` - system administrator
- `www-data` - web server user (Apache/Nginx)
- `postgres` - PostgreSQL database user

**Database Users:**
- `participadmin` - PostgreSQL database username (separate from system users)

### 4.2 Fix Laravel Permissions
```bash
# Set ownership to web server user
sudo chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs

# Storage directory permissions
sudo chmod -R 775 /DATA/participadmin.gov.md/htdocs/storage
sudo chmod -R 775 /DATA/participadmin.gov.md/htdocs/bootstrap/cache
```

### 4.3 Permission Numbers Explained

| Code | Meaning | Symbolic |
|------|---------|----------|
| 777 | All rights for everyone | `rwxrwxrwx` |
| 775 | Full for owner/group, read+execute for others | `rwxrwxr-x` |
| 755 | Full for owner, read+execute for others | `rwxr-xr-x` |
| 644 | Read/write for owner, read for others | `rw-r--r--` |

**Permission breakdown:**
- `r` (4) = read
- `w` (2) = write  
- `x` (1) = execute
- Sum = permission level (e.g., 7 = 4+2+1)

---

## 5. Common Commands Reference

### 5.1 File Operations
```bash
# Find files/directories
find / -name "backups" -type d 2>/dev/null

# List with details
ls -lah /path/to/directory

# Change ownership
sudo chown user:group filename
sudo chown -R user:group /directory

# Change permissions
chmod 775 directory/
chmod 644 file.txt
```

### 5.2 Database Operations
```bash
# View PostgreSQL databases
sudo -u postgres psql -c "\l"

# View PostgreSQL users
sudo -u postgres psql -c "SELECT usename FROM pg_user;"

# Check database size
sudo -u postgres psql -c "SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database;"
```

### 5.3 PostgreSQL Service
```bash
# Check status
sudo systemctl status postgresql

# Restart service
sudo systemctl restart postgresql

# View logs
sudo journalctl -u postgresql -n 50
```

### 5.4 Laravel Artisan Commands
```bash
# Run migrations
php artisan migrate

# Check database connection
php artisan tinker --execute="DB::connection()->getPdo();"

# Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

---

## 6. Troubleshooting

### 6.1 Permission Denied Errors
**Problem:** Laravel cannot write to storage/logs

**Solution:**
```bash
sudo chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/storage
sudo chmod -R 775 /DATA/participadmin.gov.md/htdocs/storage
```

### 6.2 PostgreSQL Connection Issues
**Problem:** "could not open relation mapping file"

**Steps:**
1. Check PostgreSQL status: `sudo systemctl status postgresql`
2. Restart PostgreSQL: `sudo systemctl restart postgresql`
3. Check file permissions: `sudo ls -la /var/lib/postgresql/*/main/global/`
4. Fix permissions: `sudo chown -R postgres:postgres /var/lib/postgresql/`

### 6.3 Git Authentication
If git asks for credentials, enter your git.itsec.md username and password.

---

## 7. Deployment Workflow

### Complete Step-by-Step Process:

1. ✅ **Create snapshot** (VM level)
2. ✅ **Backup database** (`pg_dump`)
3. ✅ **Check git status** (`git status`)
4. ✅ **Fetch updates** (`git fetch origin`)
5. ✅ **Review changes** (`git log HEAD..origin/test`)
6. ✅ **Pull updates** (`git pull origin test`)
7. ✅ **Update dependencies** (`composer install`)
8. ✅ **Run migrations** (`php artisan migrate`)
9. ✅ **Clear caches** (`php artisan cache:clear`)
10. ✅ **Test application**

---

## 8. Important Notes

### Database Dumps
- **Always create backup before migrations**
- Use timestamped filenames: `dump_YYYYMMDD_HHMMSS.sql`
- Store in `/DATA/participadmin.gov.md/backups/`
- Compressed dumps save space: `.sql.gz`

### Git Operations
- `git fetch` - downloads but doesn't apply changes
- `git pull` - downloads AND applies changes
- Always review changes before pulling

### User Context
- Run Laravel commands as `www-data`: `sudo -u www-data php artisan ...`
- Database dumps can run as any user with DB credentials
- File ownership matters for web applications

### Recovery
If deployment fails:
1. Restore VM from snapshot
2. Or restore database from dump:
```bash
sudo -u postgres psql participadmin < backup_file.sql
```

---

## 9. File Locations

| Item | Path |
|------|------|
| Application | `/DATA/participadmin.gov.md/htdocs/` |
| Backups | `/DATA/participadmin.gov.md/backups/` |
| Laravel Config | `/DATA/participadmin.gov.md/htdocs/.env` |
| Storage/Logs | `/DATA/participadmin.gov.md/htdocs/storage/logs/` |
| Artisan | `/DATA/participadmin.gov.md/htdocs/artisan` |

---

## 10. Quick Reference Commands

```bash
# Full deployment sequence
cd /DATA/participadmin.gov.md/htdocs
git pull origin test
composer install --no-dev --optimize-autoloader
php artisan migrate
php artisan config:clear
php artisan cache:clear

# Emergency rollback
# Restore from snapshot OR restore database:
sudo -u postgres psql participadmin < /DATA/participadmin.gov.md/backups/dump_[timestamp].sql
```

---

**Document Version:** 1.0  
**Date:** September 8, 2025  
**Ticket:** #99305