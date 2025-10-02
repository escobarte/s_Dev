# Linux Disk Space Cleanup Guide

## 🚨 The Problem
Your root filesystem was **97% full** with only 449MB remaining - a critical situation that needs immediate action.

```
/dev/mapper/OS-root   12G   11G  449M  97% /
```

---

## 🔍 What We Discovered

### Major Space Consumers
1. **Docker**: 3.7GB
   - overlay2 storage: 1.1GB
   - Images, containers, volumes: 2.6GB
2. **`/usr` directory**: 4.0GB
3. **Combined total**: ~7.7GB of 11GB used

---

## 📊 Key Analysis Commands

### Find What's Using Space
```bash
# Overall space analysis
sudo du -h --max-depth=2 / 2>/dev/null | sort -hr | head -20

# Find large files (over 100MB)
sudo find / -type f -size +100M 2>/dev/null

# Check specific directories
sudo du -sh /var/* | sort -hr
sudo du -sh /usr/* | sort -hr
```

### Check Docker Usage
```bash
# Docker space breakdown
sudo docker system df -v

# Check Docker storage
sudo du -sh /var/lib/docker/overlay2/
```

---

## 🧹 Cleanup Solutions

### 1. Docker Cleanup (Frees 2-3GB)

**What is overlay2?**
- Docker's storage system for container layers
- Contains all container filesystems and images
- **Never delete manually** - always use Docker commands

**Safe cleanup commands:**
```bash
# Remove all unused Docker resources (RECOMMENDED)
sudo docker system prune -a --volumes

# Or step by step:
sudo docker container prune -f  # Remove stopped containers
sudo docker image prune -a -f   # Remove unused images
sudo docker volume prune -f     # Remove unused volumes
```

### 2. Package Manager Cleanup (Frees 500MB-1GB)

```bash
# Ubuntu/Debian
sudo apt clean          # Clear package cache
sudo apt autoclean      # Remove old package files
sudo apt autoremove     # Remove unused dependencies

# CentOS/RHEL/Fedora
sudo yum clean all
# or
sudo dnf clean all
```

### 3. Log File Cleanup (Frees 200-500MB)

```bash
# Keep only 7 days of logs
sudo journalctl --vacuum-time=7d

# Or limit to 100MB total
sudo journalctl --vacuum-size=100M

# Remove old rotated logs
sudo find /var/log -name "*.log.*" -type f -mtime +7 -delete
```

### 4. Temporary Files Cleanup

```bash
# Clean old temp files (over 7 days old)
sudo find /tmp -type f -atime +7 -delete

# Clear user cache
rm -rf ~/.cache/*
```

---

## ⚡ Quick Emergency Fix

**One command to clean everything:**
```bash
sudo journalctl --vacuum-size=100M && \
sudo apt clean && \
sudo apt autoremove && \
sudo docker system prune -a -f
```

---

## ✅ Expected Results

| Action | Space Freed |
|--------|-------------|
| Docker cleanup | 2-3 GB |
| Package cleanup | 0.5-1 GB |
| Log cleanup | 0.2-0.5 GB |
| **Total** | **3-5 GB** |

**After cleanup:** Your disk should drop from 97% to approximately **60-70% usage**.

---

## ⚠️ Critical Safety Rules

1. **Never manually delete from `/var/lib/docker/overlay2/`**
   - This will corrupt Docker
   - Always use Docker commands

2. **Test services after cleanup**
   - Verify important applications still work
   - Check Docker containers restart properly

3. **Use dry-run when available**
   ```bash
   sudo docker system prune -a --dry-run
   ```

4. **Don't delete these critical directories:**
   - `/usr/bin`
   - `/usr/lib`
   - `/etc`
   - `/boot`

---

## 📝 Understanding Key Terms

### Docker overlay2
The storage driver Docker uses to manage container file systems efficiently. Each container and image is made of layers stored here.

### Package cache
Downloaded installation files kept by package managers (apt, yum, dnf). Safe to delete as packages can be re-downloaded.

### Journal logs
System logs managed by systemd. Can grow large over time but safe to vacuum to recent history.

### Dangling images
Docker images with no tags and not referenced by any container. These are leftovers from builds and updates.

---

## 🔄 Regular Maintenance Schedule

**Weekly:**
```bash
sudo docker system prune -f
```

**Monthly:**
```bash
sudo apt autoremove && sudo apt autoclean
sudo journalctl --vacuum-time=30d
```

**Quarterly:**
```bash
sudo docker system prune -a --volumes
```

---

## 📞 If Problems Persist

1. Check for application-specific logs:
   ```bash
   sudo du -sh /var/log/* | sort -hr
   ```

2. Identify large files:
   ```bash
   sudo find / -type f -size +500M 2>/dev/null
   ```

3. Check user home directories:
   ```bash
   sudo du -sh /home/* | sort -hr
   ```

4. Consider expanding the volume if legitimate data exceeds capacity

---

## 🎯 Quick Reference Card

| Problem | Command |
|---------|---------|
| Out of space | `df -h` |
| Find large dirs | `sudo du -sh /*` |
| Clean Docker | `sudo docker system prune -a` |
| Clean packages | `sudo apt clean && sudo apt autoremove` |
| Clean logs | `sudo journalctl --vacuum-time=7d` |
| Check Docker space | `sudo docker system df` |

---

**Document created:** October 1, 2025  
**Critical level:** 97% → Target: <80%  
**Primary issue:** Docker and package accumulation