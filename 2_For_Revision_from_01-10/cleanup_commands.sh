# Clean package cache (Ubuntu/Debian)
apt clean
apt autoremove
apt autoclean

# Clean package cache (RHEL/CentOS)
yum clean all
dnf clean all

# Clean systemd journal logs (keep last 7 days)
journalctl --vacuum-time=7d

# Clean old log files (be careful - check first!)
find /var/log -name "*.log.1" -delete
find /var/log -name "*.log.*.gz" -delete
find /var/log -name "*.1" -delete

# Clean tmp directories
find /tmp -type f -atime +7 -delete 2>/dev/null
find /var/tmp -type f -atime +7 -delete 2>/dev/null

# Remove core dumps
find / -name "core.*" -delete 2>/dev/null
find / -name "*.core" -delete 2>/dev/null

# Clean Docker (if installed)
docker system prune -af 2>/dev/null

# Remove old kernels (Ubuntu - keep current + 1)
apt autoremove --purge

# Clean snap cache
snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
    snap remove "$snapname" --revision="$revision"
done 2>/dev/null

# Truncate large log files instead of deleting
truncate -s 0 /var/log/syslog
truncate -s 0 /var/log/messages
truncate -s 0 /var/log/auth.log