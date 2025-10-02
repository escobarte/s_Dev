# Find largest directories (top 10)
du -h --max-depth=2 / 2>/dev/null | sort -hr | head -20

# Find large files (over 100MB)
find / -type f -size +100M 2>/dev/null | head -20

# Check specific directories for size
du -sh /var/log /tmp /root /home /opt 2>/dev/null

# Find files larger than 500MB
find / -type f -size +500M -exec ls -lh {} \; 2>/dev/null

# Check for old log files
find /var/log -name "*.log" -size +50M -ls 2>/dev/null

# Check systemd journal size
journalctl --disk-usage

# Find core dumps
find / -name "core.*" -o -name "*.core" 2>/dev/null

# Check package cache size
du -sh /var/cache/apt/ /var/cache/yum/ /var/cache/dnf/ 2>/dev/null