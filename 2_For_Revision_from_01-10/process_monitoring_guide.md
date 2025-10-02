# Process Monitoring Guide: Finding File Upload Processes

## Overview

This guide provides methods to identify which process is creating files in a specific directory on a Linux server. The context involves uploaded PDF files owned by the www-data user in a web application directory.

## Problem Statement

Files are being created in the following directory:
```
/DATA/participadmin.gov.md/htdocs/public/particip/anexe/resource_111/record_10690/
```

Files observed:
- blank_68d1238e52a54.pdf (created Sep 22 13:23)
- blank_68d12e764736e.pdf (created Sep 22 14:09)
- Owner: www-data user
- Permissions: rw-r--r--

## Goal

Determine which process or application is creating these upload files.

---

## Method 1: Real-time File Monitoring with inotifywait

**Purpose:** Monitor directory in real-time to catch file creation events as they happen.

**Installation:**
```bash
apt-get install inotify-tools
```

**Usage:**
```bash
inotifywait -m -e create,moved_to /DATA/participadmin.gov.md/htdocs/public/particip/anexe/resource_111/record_10690/
```

**Benefits:**
- Immediate notification when files are created
- Shows exact timestamp of creation
- Lightweight and easy to use

---

## Method 2: Audit System with auditd

**Purpose:** System-level auditing that tracks all file operations and the processes responsible.

**Installation:**
```bash
apt-get install auditd
```

**Setup:**
```bash
auditctl -w /DATA/participadmin.gov.md/htdocs/public/particip/anexe/ -p wa -k file_uploads
```

**View Results:**
```bash
ausearch -k file_uploads
```

**Benefits:**
- Captures process ID and user information
- Persistent logging
- Most reliable for forensic analysis

---

## Method 3: Active Process Detection

**Purpose:** Check which processes are currently accessing the directory.

**Commands:**
```bash
fuser -v /DATA/participadmin.gov.md/htdocs/public/particip/anexe/
lsof +D /DATA/participadmin.gov.md/htdocs/public/particip/anexe/
```

**Benefits:**
- Shows active file handles
- Identifies running processes using the directory

---

## Method 4: Web Server Analysis

**Purpose:** Since files are owned by www-data, investigate web server processes.

**Check Running Processes:**
```bash
ps aux | grep -E "(apache|nginx|php-fpm)"
```

**Monitor Web Server Logs:**
```bash
tail -f /var/log/apache2/access.log
tail -f /var/log/nginx/access.log
tail -f /var/log/php*fpm.log
```

**Benefits:**
- Directly correlates HTTP requests with file creation
- Shows request details (IP, URL, user agent)

---

## Method 5: Application Log Investigation

**Purpose:** Find application-specific logs that may explain file creation.

**Search for Logs:**
```bash
find /DATA/participadmin.gov.md/htdocs -name "*.log" -type f
find /var/log -name "*particip*" -type f
```

**Monitor System Journal:**
```bash
journalctl -u apache2 -f
journalctl -u nginx -f
```

---

## Method 6: Automated Monitoring Script

**Purpose:** Create a custom script that monitors and reports file creation with process context.

**Script Location:** Can be saved as monitor-uploads.sh

**Key Features:**
- Watches directory continuously
- Reports file creation with timestamp
- Lists active www-data processes at time of creation

---

## Method 7: Scheduled Task Investigation

**Purpose:** Check if files are created by automated tasks rather than user requests.

**Check Cron Jobs:**
```bash
crontab -l
cat /etc/crontab
ls -la /etc/cron.*
crontab -u www-data -l
```

**Check Systemd Timers:**
```bash
systemctl list-timers
```

---

## Recommended Approach

### Step 1: Start Real-time Monitoring
Use inotifywait to begin monitoring the directory immediately.

### Step 2: Enable Auditing
Set up auditd rules for detailed forensic logging.

### Step 3: Monitor Web Server Logs
Keep web server access logs open in parallel to correlate requests.

### Step 4: Wait for Next Upload
When a new file appears, review all three data sources to identify the process.

### Step 5: Analyze Results
Combine information from monitoring tools to determine:
- Process name and ID
- User making the request (if applicable)
- Timestamp correlation
- Application code responsible

---

## Most Likely Scenario

Given the file ownership (www-data) and location (web application directory), the files are most likely created by:

1. A web application (PHP, Python, Node.js, etc.)
2. Running under the www-data user
3. Handling HTTP file upload requests
4. Processing user-submitted forms or API calls

The inotifywait method combined with web server access log monitoring will provide the fastest path to identification.

---

## Critical Notes

- Files owned by www-data indicate web server process
- Sequential timestamps suggest user-triggered events
- File naming pattern (blank_[hash].pdf) suggests programmatic generation
- Directory structure indicates resource-based organization

## Next Steps

1. Implement monitoring using Method 1 (inotifywait)
2. Wait for next file creation event
3. Cross-reference with web server logs
4. Identify the specific application endpoint or script
5. Review application code if needed to understand upload logic