# Rancher & K3s Learning Guide

Let me help you understand Rancher and provide a cleanup plan for your servers.

## What is Rancher and Why Use It?

**Rancher** is a complete container management platform that makes it easy to deploy and manage Kubernetes clusters. Think of it as a "control tower" for Kubernetes.

### Key purposes:
- **Centralized Management**: Manage multiple Kubernetes clusters from one interface
- **User-Friendly UI**: Provides a web interface to manage K8s (much easier than kubectl commands)
- **Multi-Cluster Operations**: Deploy applications across different clusters
- **RBAC & Security**: Easy user access control and security policies
- **Cluster Provisioning**: Create and manage K8s clusters easily

### How it works:
```
[Rancher Server] (app01)
      |
      ├─── manages ───> [K3s Cluster] (app02, app03, prx01)
      ├─── manages ───> [Other Clusters] (future)
      └─── provides ───> [Web UI for users]
```

**K3s** is a lightweight Kubernetes distribution - perfect for learning and smaller environments. It uses less RAM and is simpler to set up than full Kubernetes.

---

## Server Cleanup Plan

Based on your task (Romanian: "ridică rancher cu un cluster, după idei îți ajunge vm-uri pentru un cluster cu 3 noduri" = "set up Rancher with a cluster, you should have enough VMs for a 3-node cluster"), here's your cleanup strategy:

### Phase 1: Preparation & Backup (Do First!)

**On all servers (app01, app02, app03, prx01):**

```bash
# 1. Check what's currently running
sudo systemctl list-units --type=service --state=running
sudo docker ps -a 2>/dev/null || echo "Docker not running"
sudo k3s kubectl get nodes 2>/dev/null || echo "K3s not running"

# 2. Check disk space
df -h

# 3. List installed packages that might conflict
dpkg -l | grep -E 'docker|kube|k3s|rancher' || yum list installed | grep -E 'docker|kube|k3s|rancher'

# 4. Backup important configs (just in case)
sudo cp -r /etc /root/etc-backup-$(date +%Y%m%d)
```

### Phase 2: Stop Old Services

**On all servers:**

```bash
# Stop Docker containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null
sudo docker rm $(sudo docker ps -aq) 2>/dev/null

# Stop K3s if present
sudo systemctl stop k3s 2>/dev/null
sudo systemctl stop k3s-agent 2>/dev/null

# Stop other common services (adjust based on what you found in Phase 1)
sudo systemctl stop containerd 2>/dev/null
sudo systemctl stop kubelet 2>/dev/null
```

### Phase 3: Clean K3s (if installed)

**On app01 (if it had K3s server):**
```bash
sudo /usr/local/bin/k3s-uninstall.sh 2>/dev/null || echo "K3s not installed"
```

**On app02, app03, prx01 (if they had K3s agents):**
```bash
sudo /usr/local/bin/k3s-agent-uninstall.sh 2>/dev/null || echo "K3s agent not installed"
```

### Phase 4: Clean Docker/Containers

**On all servers:**

```bash
# Remove Docker completely
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>/dev/null
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest 2>/dev/null

# Clean Docker data
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf ~/.docker

# Remove Rancher-related data
sudo rm -rf /var/lib/rancher
sudo rm -rf /etc/rancher
```

### Phase 5: Clean Network & Firewall Rules

**On all servers:**

```bash
# Reset iptables (careful - this might break SSH temporarily)
# Better to document current rules first:
sudo iptables-save > /root/iptables-backup-$(date +%Y%m%d).rules

# Remove CNI networks
sudo rm -rf /var/lib/cni
sudo rm -rf /etc/cni

# Remove virtual interfaces created by K3s
sudo ip link delete flannel.1 2>/dev/null
sudo ip link delete cni0 2>/dev/null
```

### Phase 6: System Updates & Preparation

**On all servers:**

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y  # Debian/Ubuntu
# OR
sudo yum update -y  # RHEL/CentOS

# Install required packages
sudo apt-get install -y curl wget htop net-tools  # Debian/Ubuntu
# OR
sudo yum install -y curl wget htop net-tools  # RHEL/CentOS

# Disable swap (required for Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Set hostnames (if not already set)
# On app01:
sudo hostnamectl set-hostname rancher-server
# On app02:
sudo hostnamectl set-hostname k3s-node1
# On app03:
sudo hostnamectl set-hostname k3s-node2
# On prx01:
sudo hostnamectl set-hostname k3s-node3
```

### Phase 7: Configure /etc/hosts

**On all servers, add:**

```bash
sudo tee -a /etc/hosts << EOF
10.100.93.5 rancher-server app01
10.100.93.6 k3s-node1 app02
10.100.93.7 k3s-node2 app03
10.100.93.3 k3s-node3 prx01
EOF
```

### Phase 8: Reboot

```bash
# Reboot all servers to ensure clean state
sudo reboot
```

---

## Post-Cleanup Verification

After reboot, verify clean state on all servers:

```bash
# 1. Check no K3s processes
ps aux | grep k3s

# 2. Check no Docker
sudo docker ps 2>/dev/null || echo "Docker not found - Good!"

# 3. Check disk space
df -h

# 4. Check memory
free -h

# 5. Verify network connectivity between nodes
ping -c 3 10.100.93.5
ping -c 3 10.100.93.6
ping -c 3 10.100.93.7
ping -c 3 10.100.93.3
```

---

## Your Architecture Concerns

**RAM Distribution Analysis:**
- app01 (Rancher): 4GB ✓ (minimum for Rancher is 4GB)
- app02: 4GB ✓ (good for worker node)
- app03: 2GB ⚠️ (minimum, might struggle under load)
- prx01: 2GB ⚠️ (minimum, might struggle under load)

**For K3s**, this should work for learning/testing, but in production you'd want 4GB+ per node.

---

## Next Steps (After Cleanup)

1. **Install K3s on app02, app03, prx01** (create the cluster)
2. **Install Rancher on app01** (the management server)
3. **Import the K3s cluster into Rancher**
4. **Deploy test applications**

Would you like me to provide the detailed installation steps for Rancher and K3s cluster setup after you complete the cleanup?