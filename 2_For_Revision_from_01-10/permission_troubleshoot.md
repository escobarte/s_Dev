# Permission Troubleshooting Summary

## Problem Overview

A folder in a Laravel application had incorrect ownership and permissions:

```
drwxr-xr-x    5 participadmin participadmin   4096 Sep 22 13:23 resource_111/
```

All other folders in the same directory were owned by `www-data:www-data` with `777` permissions, but `resource_111` was owned by `participadmin:participadmin` with `755` permissions.

## Initial Investigation Steps

### System Process Checks

Attempted to find what was running under the `participadmin` user:

- Check running processes: `ps aux | grep participadmin`
- Check cron jobs: `crontab -u participadmin -l`
- Check systemd services: `systemctl list-units --type=service`
- Check network listeners: `netstat -tulnp | grep participadmin`

Result: No processes found running as `participadmin` user.

### Laravel Application Checks

Investigated Laravel-specific configurations:

- Laravel filesystem configuration: `config/filesystems.php`
- Environment variables: `.env` file
- PHP-FPM pool configurations: `/etc/php*/fpm/pool.d/`
- File upload handling in controllers
- Queue workers and artisan commands
- Laravel logs: `storage/logs/laravel.log`

## Critical Discovery

### Laravel Log Analysis

The application logs revealed the root cause:

**Error Location:**
- File: `/app/Extensions/Attach.php` at line 187
- Controller: `DocumentsController->uploadWorkingGroupFile()`
- Resource ID: 111 (matching the problematic folder `resource_111`)

**Key Finding:**

The file upload process in the Laravel application was creating files and folders with the wrong ownership. The upload was happening through a background process or service running as the `participadmin` user.

### Most Likely Causes

1. Supervisor process running Laravel queue workers as `participadmin` user
2. PHP-FPM pool configured to run as `participadmin`
3. Custom file upload code that explicitly sets ownership

The logs showed "SUPERVISOR RUNNING OK" message, indicating supervisor was managing background processes.

## Recommended Investigation Commands

### Check Supervisor Configuration

```bash
find /etc/supervisor* -name "*.conf" | xargs grep -l "participadmin"
ps aux | grep -E "(queue:work|queue:listen|supervisord)"
```

### Check PHP-FPM Pools

```bash
grep -r "participadmin" /etc/php*/fpm/pool.d/
ps aux | grep php
```

### Examine Upload Code

```bash
cat /DATA/participadmin.gov.md/htdocs/app/Extensions/Attach.php | sed -n '180,200p'
cat /DATA/participadmin.gov.md/htdocs/app/Http/Controllers/Particip/DocumentsController.php | sed -n '790,800p'
```

## Quick Fix Solutions

### Immediate Permission Fix

```bash
# Fix ownership
chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/public/particip/anexe/resource_111/

# Fix permissions
chmod -R 777 /DATA/participadmin.gov.md/htdocs/public/particip/anexe/resource_111/
```

### Secure Laravel Storage Permissions

```bash
find /DATA/participadmin.gov.md/htdocs/storage -type f -exec chmod 644 {} +
find /DATA/participadmin.gov.md/htdocs/storage -type d -exec chmod 755 {} +
```

This sets:
- Files: 644 (owner: read/write, group/others: read only)
- Directories: 755 (owner: full access, group/others: read/execute)

## Permission Reference

### Understanding Permission Numbers

- 7 = read + write + execute (rwx)
- 6 = read + write (rw-)
- 5 = read + execute (r-x)
- 4 = read only (r--)

### Common Permission Patterns

- 777: Full access for everyone (security risk)
- 755: Owner full access, others read/execute only
- 644: Owner read/write, others read only

### Permission Format

```
drwxrwxrwx owner group
```

- First character: d = directory, - = file
- Next 3 characters: owner permissions
- Next 3 characters: group permissions
- Last 3 characters: other users permissions

## Root Cause Analysis

The issue stems from a Laravel application component that handles file uploads for working group documents. When files are uploaded to resource 111, the background process or service executing the upload runs as the `participadmin` user instead of the expected `www-data` user.

This creates a permission mismatch where:
- The web server (Apache/Nginx) runs as `www-data`
- The upload process runs as `participadmin`
- Files created by `participadmin` cannot be properly accessed by the web server

## Long-term Solution

To permanently fix this issue:

1. Identify the supervisor or PHP-FPM configuration running as `participadmin`
2. Change the process to run as `www-data` user
3. Set proper umask in the application configuration
4. Ensure Laravel's file upload code doesn't explicitly set ownership
5. Configure proper directory permissions in Laravel's `filesystems.php`

## Important Notes

- Security Warning: 777 permissions give full access to everyone and should be used cautiously
- The `participadmin` user appears to be used for background processes or queue workers
- All file operations should ideally run as the same user as the web server for consistency
- Regular permission audits should be performed to catch similar issues early