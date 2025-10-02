# Kubernetes Setup and Troubleshooting Guide

## Storage Requirements for Kubernetes System Files

### Kubernetes Core Binaries
Location: `/usr/bin/`

- kubeadm: 40-50 MB
- kubelet: 100-120 MB
- kubectl: 40-50 MB
- **Total: ~200 MB**

### System Configuration Files
Location: `/etc/kubernetes/`

- Contains YAML configs, certificates, and keys
- **Total: Under 10 MB**

### Service Files
Location: `/etc/systemd/system/`

- Systemd unit files for Kubernetes services
- **Total: Under 1 MB**

### Combined Storage Impact
**Total: 210-220 MB** - minimal footprint for essential system files.

**Note:** The real storage consumers are container images, etcd data, and application logs, which should be relocated to separate storage.

---

## Flannel CNI Plugin

### What is Flannel
Flannel is a Container Network Interface (CNI) plugin that provides networking between pods across different nodes in a Kubernetes cluster.

### Core Functionality
- Creates a virtual overlay network for pod-to-pod communication
- Assigns each node a unique subnet from a larger network range
- Routes traffic between pods on different physical nodes

### How It Works
1. **IP Management:** Assigns subnets to each node (e.g., 10.244.1.0/24, 10.244.2.0/24)
2. **Packet Handling:** Encapsulates packets for cross-node communication
3. **Routing:** Maintains routing tables for pod communication

### Key Features
- Simple setup and configuration
- Multiple backend options (VXLAN most common)
- Lightweight with minimal resource overhead
- Cross-platform support (Linux, Windows)

### Installation
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

### Alternatives
Other CNI options include Calico, Weave, and Cilium.

---

## Configuring Custom etcd Data Directory

### Problem
The `--etcd-data-dir` flag does not exist for `kubeadm init` command.

### Solution
Use a kubeadm configuration file instead of command-line flags.

### Step 1: Create Configuration File
Create `kubeadm-config.yaml`:

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: "10.244.0.0/16"
etcd:
  local:
    dataDir: "/opt/kubernetes/etcd"
```

### Step 2: Prepare Directory
```bash
sudo mkdir -p /opt/kubernetes/etcd
sudo chown -R root:root /opt/kubernetes/etcd
```

### Step 3: Initialize Cluster
```bash
sudo kubeadm init --config=kubeadm-config.yaml --v=5
```

### Advanced Configuration
For more control, use a complete configuration:

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "YOUR_NODE_IP"
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: "10.244.0.0/16"
etcd:
  local:
    dataDir: "/opt/kubernetes/etcd"
    serverCertSANs:
    - "YOUR_NODE_IP"
    peerCertSANs:
    - "YOUR_NODE_IP"
```

---

## Installing crictl

### What is crictl
CLI tool for interacting with container runtimes that implement the Container Runtime Interface (CRI). Essential for Kubernetes troubleshooting.

### Installation Method 1: Manual Download
```bash
VERSION="v1.28.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz
```

### Installation Method 2: Package Manager
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install cri-tools

# Or using snap
sudo snap install crictl
```

### Configuration
```bash
# For containerd (most common)
sudo crictl config runtime-endpoint unix:///run/containerd/containerd.sock

# For CRI-O
sudo crictl config runtime-endpoint unix:///var/run/crio/crio.sock
```

### Verification
```bash
crictl version
crictl info
```

### Common Commands
```bash
crictl ps          # List containers
crictl pods        # List pods
crictl images      # List images
crictl pull nginx  # Pull an image
```

---

## Installing netcat (nc)

### What is netcat
Network utility for testing connectivity, particularly useful for checking if Kubernetes ports are accessible.

### Installation

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install netcat-openbsd
```

**CentOS/RHEL/Rocky Linux:**
```bash
sudo yum install nc
# OR
sudo dnf install nc
```

**Alternative (nmap-ncat):**
```bash
# Ubuntu/Debian
sudo apt-get install nmap

# CentOS/RHEL/Rocky
sudo yum install nmap-ncat
```

### Common Usage for Kubernetes
```bash
# Test if a port is open
nc -nz <IP> <PORT>

# Examples:
nc -nz 10.96.0.1 443      # Kubernetes API
nc -nz 127.0.0.1 6443     # API server locally
nc -nz 127.0.0.1 2379     # etcd
nc -nz 127.0.0.1 10250    # kubelet

# With timeout
timeout 5 nc -nz 192.168.1.100 22
```

### Flag Explanations
- `-n`: Don't resolve hostnames (faster)
- `-z`: Zero-I/O mode (scan only, no data transfer)

### Alternative Testing Methods
```bash
# Using telnet
telnet <IP> <PORT>

# Using curl (HTTP only)
curl -I http://<IP>:<PORT>

# Using bash built-in
timeout 1 bash -c '</dev/tcp/IP/PORT' 2>/dev/null && echo "Port open" || echo "Port closed"
```

---

## Key Takeaways

1. **Storage Planning:** Kubernetes system files require minimal storage (around 220 MB). Focus on relocating container images, etcd data, and logs for significant storage savings.

2. **Network Configuration:** Flannel provides simple, reliable pod networking. Install it after cluster initialization using the pod network CIDR 10.244.0.0/16.

3. **Custom Paths:** Always use kubeadm configuration files instead of command-line flags for custom paths like etcd data directory.

4. **Essential Tools:** Install crictl for container runtime troubleshooting and netcat for network connectivity testing.

5. **Configuration Files:** Keep kubeadm configuration files for future reference and cluster maintenance.