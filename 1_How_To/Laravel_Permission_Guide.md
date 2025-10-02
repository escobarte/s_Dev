# Laravel Storage Permissions & Logs Guide

## 🔐 Setting Storage Permissions

### The Command Explained

```bash
sudo chmod -R 775 /DATA/participadmin.gov.md/htdocs/storage
```

### Command Breakdown

- **sudo** - Run as administrator/superuser
- **chmod** - Change file permissions
- **-R** - Recursive (applies to all files and folders inside)
- **775** - Permission code
- **/DATA/participadmin.gov.md/htdocs/storage** - Target directory path

### Understanding Permission Numbers (775)

| Position  | Value | Owner  | Permissions            |
| --------- | ----- | ------ | ---------------------- |
| 1st digit | **7** | Owner  | Read + Write + Execute |
| 2nd digit | **7** | Group  | Read + Write + Execute |
| 3rd digit | **5** | Others | Read + Execute         |

### Permission Values

- **4** = Read (r)
- **2** = Write (w)
- **1** = Execute (x)
- **7** = 4+2+1 = Read + Write + Execute
- **5** = 4+1 = Read + Execute

---

## ⚠️ Security Considerations

### Why 775 Can Be Risky

1. **Too permissive** - Group members have write access
2. **Government domain** - Extra caution needed for .gov.md sites
3. **Web-accessible location** - htdocs is usually in web root
4. **Execute permissions** - May not be needed for all files

### ✅ Recommended Safer Alternative

```bash
sudo chmod -R 755 /DATA/participadmin.gov.md/htdocs/storage
```

**Why 755 is better:**

- Removes group write access
- Still allows web server to read files
- Reduces security vulnerabilities

### Best Practices

```bash
# 1. Check current permissions first
ls -la /DATA/participadmin.gov.md/htdocs/storage

# 2. Set proper ownership
sudo chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/storage

# 3. Apply appropriate permissions
sudo chmod -R 755 /DATA/participadmin.gov.md/htdocs/storage

# 4. Allow write access only where needed (logs, cache, sessions)
sudo chmod -R 775 /DATA/participadmin.gov.md/htdocs/storage/logs
sudo chmod -R 775 /DATA/participadmin.gov.md/htdocs/storage/framework
```

---

## 📋 Reading Laravel Logs

### Default Log Location

```
/path/to/project/storage/logs/laravel.log
```

For your case:

```
/DATA/participadmin.gov.md/htdocs/storage/logs/laravel.log
```

---

## 🖥️ Terminal Commands for Log Reading

### View Live Logs (Real-time)

```bash
tail -f storage/logs/laravel.log
```

**Use case:** Monitor errors as they happen

### View Last 50 Lines

```bash
tail -50 storage/logs/laravel.log
```

### View Last 100 Lines

```bash
tail -100 storage/logs/laravel.log
```

### View Entire Log File

```bash
cat storage/logs/laravel.log
```

**Warning:** Can be very long!

### View with Pagination

```bash
less storage/logs/laravel.log
```

**Controls:** Arrow keys to scroll, `q` to quit

---

## 🔍 Searching and Filtering Logs

### Search for Specific Text

```bash
grep "ERROR" storage/logs/laravel.log
```

### Search Multiple Levels

```bash
grep "ERROR\|CRITICAL\|EMERGENCY" storage/logs/laravel.log
```

### Search Today's Logs

```bash
grep "$(date '+%Y-%m-%d')" storage/logs/laravel.log
```

### Search Specific Date

```bash
grep "2025-10-01" storage/logs/laravel.log
```

### Count Errors

```bash
grep "ERROR" storage/logs/laravel.log | wc -l
```

### Show Line Numbers

```bash
grep -n "ERROR" storage/logs/laravel.log
```

### Search with Context (3 lines before and after)

```bash
grep -C 3 "ERROR" storage/logs/laravel.log
```

---

## 📊 Laravel Log Levels

### Priority Order (Highest to Lowest)

| Level         | Severity    | When to Use                                 |
| ------------- | ----------- | ------------------------------------------- |
| **EMERGENCY** | 🔴 Critical | System is unusable                          |
| **ALERT**     | 🔴 Critical | Action must be taken immediately            |
| **CRITICAL**  | 🔴 Critical | Critical conditions                         |
| **ERROR**     | 🟠 High     | Runtime errors that need attention          |
| **WARNING**   | 🟡 Medium   | Exceptional occurrences that are not errors |
| **NOTICE**    | 🔵 Low      | Normal but significant events               |
| **INFO**      | 🔵 Low      | Interesting events                          |
| **DEBUG**     | ⚪ Minimal   | Detailed debug information                  |

---

## 🛠️ Advanced Log Analysis

### Find Most Common Errors

```bash
grep "ERROR" storage/logs/laravel.log | sort | uniq -c | sort -rn | head -10
```

### Show Only Exception Names

```bash
grep -oP '(?<=Exception\().*?(?=:)' storage/logs/laravel.log | sort | uniq -c
```

### Filter by Time Range

```bash
grep "2025-10-01 1[0-5]:" storage/logs/laravel.log
```

Shows logs between 10:00 and 15:59

### Export Errors to File

```bash
grep "ERROR" storage/logs/laravel.log > errors_today.txt
```

---

## 🌐 Web-Based Log Viewer

### Install Laravel Log Viewer Package

```bash
composer require rap2hpoutre/laravel-log-viewer
```

### Access in Browser

```
http://your-domain.com/logs
```

### Benefits

- ✅ User-friendly interface
- ✅ Filter by level
- ✅ Search functionality
- ✅ No terminal needed

---

## 📝 Log Entry Structure

### Typical Laravel Log Entry

```
[2025-10-01 14:30:45] production.ERROR: Division by zero
{"exception":"[object] (ErrorException(code: 0): Division by zero at /path/to/file.php:123)"}
```

### Components Explained

- **[2025-10-01 14:30:45]** - Timestamp
- **production** - Environment (local/staging/production)
- **ERROR** - Log level
- **Division by zero** - Error message
- **{"exception":...}** - Detailed context (JSON format)

---

## 🚀 Quick Reference Commands

### Essential Commands Cheat Sheet

```bash
# Live monitoring
tail -f storage/logs/laravel.log

# Last 50 entries
tail -50 storage/logs/laravel.log

# Search errors
grep "ERROR" storage/logs/laravel.log

# Today's errors
grep "$(date '+%Y-%m-%d')" storage/logs/laravel.log | grep "ERROR"

# Count total errors
grep "ERROR" storage/logs/laravel.log | wc -l

# Clear old logs (be careful!)
> storage/logs/laravel.log
```

---

## 💡 Best Practices

### For Permissions

1. ✅ Use **755** as default
2. ✅ Use **775** only for directories that need write access
3. ✅ Set correct ownership (www-data or nginx user)
4. ✅ Test after changing permissions
5. ✅ Document changes in your deployment notes

### For Log Management

1. ✅ Monitor logs regularly
2. ✅ Set up log rotation to prevent huge files
3. ✅ Archive old logs
4. ✅ Set up alerts for CRITICAL/EMERGENCY logs
5. ✅ Review ERROR logs daily
6. ✅ Use `.gitignore` to exclude logs from version control

---

## 🔧 Troubleshooting

### Can't Write to Logs?

```bash
# Check permissions
ls -la storage/logs/

# Fix ownership
sudo chown -R www-data:www-data storage/logs/

# Fix permissions
sudo chmod -R 775 storage/logs/
```

### Log File Too Large?

```bash
# Check size
du -h storage/logs/laravel.log

# Archive and clear
mv storage/logs/laravel.log storage/logs/laravel-$(date +%Y%m%d).log
touch storage/logs/laravel.log
sudo chown www-data:www-data storage/logs/laravel.log
```

### Can't Read Logs?

```bash
# Add yourself to web server group
sudo usermod -a -G www-data your-username

# Then logout and login again
```

---

## 📞 Additional Resources

- **Laravel Documentation:** https://laravel.com/docs/logging
- **File Permissions Guide:** https://www.linux.com/training-tutorials/understanding-linux-file-permissions/
- **Laravel Log Viewer:** https://github.com/rap2hpoutre/laravel-log-viewer

---

## ✅ Quick Checklist

**After deployment or permission changes:**

- [ ] Verify storage directory permissions (755 or 775)
- [ ] Check ownership (www-data or nginx)
- [ ] Test log writing capability
- [ ] Review recent error logs
- [ ] Set up log rotation
- [ ] Configure monitoring/alerts
- [ ] Document any custom permission settings

---

**Created:** October 2025  
**For:** participadmin.gov.md Laravel application  
**Version:** 1.0