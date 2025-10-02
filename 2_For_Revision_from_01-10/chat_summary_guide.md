# System Resource Management Summary

## Overview
This guide summarizes a troubleshooting session for a Linux server (sas-lab-app02) experiencing critical disk and memory resource constraints.

---

## Initial Problem Assessment

### Disk Space Issues
- **System:** 11.4GB total capacity
- **Used:** 10.6GB (93% full)
- **Available:** 822MB remaining
- **Status:** CRITICAL - requires immediate attention

### Memory Issues
- **Total RAM:** 3.8GB
- **Used RAM:** 3.4GB (89% utilized)
- **Available:** 366MB
- **Swap:** 0B (not configured, but 2GB swap.img file exists on disk)

---

## Key Findings

### Primary Memory Consumer
**Elasticsearch is consuming 65.4% of total system RAM**

**Process Details:**
- PID: 2569523
- Memory Usage: 2.6GB (2,592MB)
- Heap Allocation: 1.9GB (-Xms1934m -Xmx1934m)
- Direct Memory: 1GB additional
- User: elasticsearch

**Other Processes:**
- Docker daemon: 37MB (normal)
- Containerd: 29MB (normal)
- GitLab Runner: 28MB (normal)
- PHP-FPM workers: 23MB each (normal)

---

## Recommended Solutions

### For Disk Space Management

**Step 1: Identify Large Consumers**
```bash
du -h --max-depth=2 / 2>/dev/null | sort -hr | head -20
find / -type f -size +100M 2>/dev/null
journalctl --disk-usage
```

**Step 2: Safe Cleanup Operations**
```bash
# Clean package cache
apt clean && apt autoremove

# Limit systemd journal to 100MB
journalctl --vacuum-size=100M

# Remove old temporary files
find /tmp -type f -atime +7 -delete
find /var/tmp -type f -atime +7 -delete

# Clean old log files
find /var/log -name "*.log.*.gz" -delete
```

**Step 3: Consider Swap File**
The 2GB swap.img file can potentially be reduced if sufficient RAM is available after optimization.

---

### For Memory Management

**Option 1: Stop Elasticsearch (if not required)**
```bash
sudo systemctl stop elasticsearch
sudo systemctl disable elasticsearch
```
**Result:** Frees approximately 2.6GB immediately

**Option 2: Reduce Elasticsearch Heap Size (if required)**
```bash
# Backup current configuration
sudo cp /etc/elasticsearch/jvm.options /etc/elasticsearch/jvm.options.backup

# Edit configuration file
sudo nano /etc/elasticsearch/jvm.options
```

**Modify these lines:**
```
-Xms512m
-Xmx512m
```

**Restart service:**
```bash
sudo systemctl restart elasticsearch
```
**Result:** Frees approximately 1.4GB

---

## Diagnostic Commands

### Memory Analysis (Human-Readable Format)
```bash
ps aux --sort=-%mem | head -15 | awk '
BEGIN {
    printf "%-6s %-8s %-12s %s\n", "MEM%", "SIZE", "USER", "PROCESS"
}
NR > 1 {
    mem_mb = int($6 / 1024)
    if (mem_mb >= 1024) {
        size = sprintf("%.1fGB", mem_mb/1024)
    } else {
        size = sprintf("%dMB", mem_mb)
    }
    printf "%-6.1f %-8s %-12s %s\n", $4, size, substr($1, 1, 10), $11
}'
```

### System Memory Overview
```bash
free -h
cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached)"
```

### Disk Space Analysis
```bash
duf /
du -sh /var/log /tmp /root /home /opt
df -h
```

---

## File Organization Recommendations

### Project Folders
**Original folder names suggested replacements:**

**For ansible-lab folder:**
- ansible-practice
- ansible-workspace
- ansible-sandbox
- ansible-training

**For zabbix folder:**
- zabbix-monitoring
- zabbix-config
- zabbix-lab
- zabbix-setup

---

## Critical Actions Required

### Immediate Priority
1. Address Elasticsearch memory consumption (choose Option 1 or 2)
2. Clean disk space to avoid system instability
3. Verify Elasticsearch is actually required for operations

### Medium Priority
1. Implement regular cleanup schedule for logs and temp files
2. Monitor disk usage with automated alerts at 80% capacity
3. Consider expanding disk space if current allocation is insufficient for workload

### Long-Term Recommendations
1. Configure proper swap space or reduce swap file size after memory optimization
2. Implement log rotation policies
3. Regular monitoring of resource utilization trends
4. Document all services and their resource requirements

---

## Expected Results After Optimization

### Memory Improvement
- **Before:** 3.4GB used (89% utilization)
- **After (Option 1):** ~800MB used (21% utilization)
- **After (Option 2):** ~2GB used (52% utilization)

### Disk Space Improvement
- **Current:** 822MB free (7% available)
- **After cleanup:** 2-3GB free (estimated 18-26% available)

---

## Additional Resources

### For Elasticsearch Configuration
- Official documentation: /etc/elasticsearch/jvm.options
- Check service status: `systemctl status elasticsearch`
- View logs: `journalctl -u elasticsearch -f`

### For System Monitoring
- Memory: `free -h`, `top`, `htop`
- Disk: `df -h`, `duf`, `ncdu`
- Processes: `ps aux`, `systemctl list-units`

---

## Notes

- All commands should be executed with appropriate privileges (sudo where needed)
- Always backup configuration files before making changes
- Test changes in non-production environment when possible
- Monitor system stability after implementing changes
- Document all modifications for future reference

---

**Generated:** October 1, 2025  
**System:** sas-lab-app02  
**OS:** Linux (Ubuntu/Debian-based)  
**Critical Issues:** Disk space at 93%, Memory usage at 89%