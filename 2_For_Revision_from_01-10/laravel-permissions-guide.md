# Laravel File Permissions Troubleshooting Guide

## Problem Summary
Laravel log files and uploaded directories were being created with incorrect ownership (`participadmin:participadmin` instead of `www-data:www-data`), causing permission issues in the application.

## Root Causes Identified

### 1. **Apache Configuration Issue** ⚠️
The Apache virtual host was configured with `AssignUserId participadmin participadmin`, forcing all web requests to run as the wrong user.

**Location:** `/etc/apache2/sites-available/admin.particip.gov.md.conf`

### 2. **Cron Job Running as Wrong User**
Laravel's scheduler was running under `participadmin` user instead of `www-data`.

### 3. **Supervisor Worker Configuration**
Queue workers were configured to run as `participadmin` in the supervisor configuration.

---

## Solutions Applied

### 1. Fix Apache Configuration (CRITICAL)

```bash
# Edit Apache config
sudo nano /etc/apache2/sites-available/admin.particip.gov.md.conf

# Change from:
AssignUserId participadmin participadmin

# To:
AssignUserId www-data www-data

# Test and reload
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### 2. Move Cron Job to Correct User

```bash
# Remove from participadmin
sudo crontab -u participadmin -e
# Comment out or remove the schedule:run line

# Add to www-data
sudo crontab -u www-data -e
# Add:
* * * * * php /DATA/participadmin.gov.md/htdocs/artisan schedule:run >> /dev/null 2>&1
```

### 3. Update Supervisor Configuration

```bash
# Edit worker config
sudo nano /etc/supervisor/conf.d/laravel-worker.conf

# Change:
user=participadmin
# To:
user=www-data

# Add for file permissions:
umask=000

# Apply changes
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart all
```

### 4. Fix File Permissions (777 requirement)

**Option A: Laravel Config (Recommended)**
```php
// In config/logging.php, add to 'daily' array:
'permission' => 0777,
```

**Option B: Using ACL**
```bash
sudo setfacl -R -d -m u::rwx,g::rwx,o::rwx /DATA/participadmin.gov.md/htdocs/storage/logs/
```

### 5. Fix Existing Files

```bash
# Change ownership
sudo chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/storage/
sudo chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/public/particip/anexe/

# Set correct permissions
sudo find /DATA/participadmin.gov.md/htdocs/storage -type d -exec chmod 755 {} +
sudo find /DATA/participadmin.gov.md/htdocs/storage -type f -exec chmod 644 {} +
```

---

## Diagnostic Commands Used

### Find Where User is Configured

```bash
# Comprehensive check
echo "=== CRON ===" && sudo crontab -u participadmin -l;
echo "=== SUPERVISOR ===" && grep -r "user.*=.*participadmin" /etc/supervisor/;
echo "=== APACHE ===" && grep -r "participadmin" /etc/apache2/ | grep -v "^#";
echo "=== SYSTEMD ===" && grep -r "User=participadmin" /etc/systemd/;
```

### Check Active Processes

```bash
# See what's running as participadmin
ps aux | grep "^participadmin"

# Check file ownership statistics
find /DATA/participadmin.gov.md/htdocs -type f -printf '%u\n' | sort | uniq -c
```

### Monitor File Creation

```bash
# Watch logs in real-time
tail -f /DATA/participadmin.gov.md/htdocs/storage/logs/laravel-$(date +%Y-%m-%d).log

# Check file ownership
ls -la /DATA/participadmin.gov.md/htdocs/storage/logs/
```

---

## Key Files and Locations

| Component | Configuration File | Purpose |
|-----------|-------------------|---------|
| **Apache** | `/etc/apache2/sites-available/admin.particip.gov.md.conf` | Virtual host configuration |
| **Supervisor** | `/etc/supervisor/conf.d/laravel-worker.conf` | Queue worker configuration |
| **Laravel Logs** | `/DATA/participadmin.gov.md/htdocs/storage/logs/` | Application logs |
| **Laravel Config** | `/DATA/participadmin.gov.md/htdocs/config/logging.php` | Logging configuration |
| **Uploaded Files** | `/DATA/participadmin.gov.md/htdocs/public/particip/anexe/` | User uploads |
| **Scheduler** | `/DATA/participadmin.gov.md/htdocs/app/Console/Kernel.php` | Scheduled tasks |

---

## Important Notes

### Laravel Scheduler
- Runs every minute via cron (`* * * * *`)
- Checks `app/Console/Kernel.php` for scheduled tasks
- Must run as same user as web server (`www-data`)

### File Permissions
- **755** for directories: `rwxr-xr-x` (owner can do everything, others can read/execute)
- **644** for files: `rw-r--r--` (owner can read/write, others can read)
- **777**: `rwxrwxrwx` (everyone can do everything - use with caution)

### AssignUserId Directive
- Part of Apache MPM-ITK module
- Forces all PHP processes for a virtual host to run as specified user
- Affects all file creation through web interface

---

## Verification Checklist

- [ ] Apache running with correct user (`AssignUserId www-data www-data`)
- [ ] Cron jobs moved to `www-data` user
- [ ] Supervisor workers configured with `user=www-data`
- [ ] Existing files ownership changed to `www-data:www-data`
- [ ] New log files created with correct ownership
- [ ] Upload directories created with correct ownership
- [ ] File permissions set correctly (777 if required)

---

## Quick Troubleshooting

**If files still created with wrong owner:**
1. Check Apache hasn't been reloaded: `sudo systemctl reload apache2`
2. Verify all Apache configs: `grep -r "AssignUserId" /etc/apache2/sites-enabled/`
3. Check supervisor status: `sudo supervisorctl status`
4. Look for missed cron jobs: `for user in participadmin www-data root; do sudo crontab -u $user -l; done`

**If permissions are wrong (not 777):**
1. Check Laravel config: `grep permission /DATA/participadmin.gov.md/htdocs/config/logging.php`
2. Clear Laravel cache: `sudo -u www-data php artisan config:cache`
3. Check umask in supervisor: `grep umask /etc/supervisor/conf.d/*.conf`

---

## Security Considerations

⚠️ **Warning:** File permissions of `777` are very permissive. Consider:
- Using `666` (no execute) for log files instead
- Using `664` with proper group membership
- Implementing ACLs for more granular control

---

*Document generated from troubleshooting session on Laravel file permission issues*