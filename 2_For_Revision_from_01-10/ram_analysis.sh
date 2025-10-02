# Top memory consuming processes
ps aux --sort=-%mem | head -20

# Alternative view with better formatting
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -20

# Memory usage by process (top command snapshot)
top -b -n1 -o %MEM | head -20

# Detailed memory breakdown
cat /proc/meminfo

# Memory usage by user
ps hax -o rss,user | awk '{a[$2]+=$1;}END{for(i in a)print i" "int(a[i]/1024)"MB";}' | sort -rnk2

# System memory map
vmstat -s

# Check for memory leaks (processes with high virtual memory)
ps -eo pid,vsz,rss,comm --sort=-vsz | head -15

# Memory usage by systemd services
systemctl status --no-pager -l | grep -E "(Active|Memory)"

# Detailed per-process memory breakdown
smem -t -k 2>/dev/null || echo "smem not installed"

# Check shared memory usage
ipcs -m

# Memory usage by cgroups (if systemd)
find /sys/fs/cgroup -name "memory.usage_in_bytes" 2>/dev/null | head -10 | while read f; do
    echo "$f: $(cat $f 2>/dev/null)"
done