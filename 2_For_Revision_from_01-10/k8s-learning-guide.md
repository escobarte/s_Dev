# Kubernetes Learning Guide: From Zero to Cluster

## 📋 Table of Contents
1. [Initial Setup Decision](#initial-setup-decision)
2. [Kubernetes Architecture Overview](#kubernetes-architecture-overview)
3. [Why System Preparation is Needed](#why-system-preparation-is-needed)
4. [Container Runtime Explained](#container-runtime-explained)
5. [Cleaning Previous Installations](#cleaning-previous-installations)
6. [Fresh Minikube Installation](#fresh-minikube-installation)

---

## 🎯 Initial Setup Decision

### Available Options for 4 Servers in vSphere

| Option | Best For | Pros | Cons |
|--------|----------|------|------|
| **Minikube** | Local development | Simple, single command | Single node only |
| **kubeadm** | Learning & Production-like | Real K8s experience, multi-node | More complex setup |
| **k3s** | Lightweight learning | Fast setup, low resources | Some features missing |

**Recommendation**: Use **kubeadm** for real learning experience with your 4 servers.

### Suggested Architecture for 4 Servers

**Option 1 - Simple** (Recommended for start):
- 1 master node
- 3 worker nodes

**Option 2 - High Availability**:
- 3 master nodes (etcd quorum)
- 1 worker node

---

## 🏗️ Kubernetes Architecture Overview

### Control Plane Components (Master Node)

**etcd**
- Key-value store for all cluster data
- If etcd dies = cluster dies
- Only component that stores state

**kube-apiserver**
- REST API entry point
- Only component talking to etcd
- All others (including kubectl) talk to API server

**kube-scheduler**
- Decides which node runs each pod
- Considers: resources, constraints, affinity

**kube-controller-manager**
- Runs controller loops
- Example: ReplicaSet controller maintains pod count

### Worker Node Components

**kubelet**
- Agent on each node
- Talks to API server
- Manages pods through container runtime

**container runtime**
- Actually runs containers
- Options: containerd, CRI-O (Docker deprecated)

**kube-proxy**
- Configures network rules (iptables/ipvs)
- Makes Services work by routing traffic to pods

### Network Model Requirements

1. **Every pod gets unique IP** - No IP sharing
2. **Pod-to-pod communication** - Direct, no NAT
3. **Node-to-pod communication** - Agents can reach all local pods

⚠️ **Important**: Kubernetes doesn't implement networking itself - needs CNI plugin (Flannel, Calico, etc.)

---

## 🔧 Why System Preparation is Needed

### Required System Changes

**Disable Swap**
```bash
swapoff -a
```
- Kubelet refuses to work with swap
- Logic: swap = memory shortage = poor pod performance

**Kernel Modules**
- `br_netfilter` - Makes iptables see bridged traffic
- `overlay` - For container image layer filesystem

**Sysctl Parameters**
- `net.bridge.bridge-nf-call-iptables = 1` - Bridge traffic goes through iptables
- `net.ipv4.ip_forward = 1` - Node acts as router for pods

---

## 🐳 Container Runtime Explained

### Why Not Docker?

Docker was "fat" - included daemon, CLI, and extras. Kubernetes only needs the runtime part.

**Timeline**:
- Before v1.24: Docker supported via dockershim
- v1.24+: dockershim removed
- Now: Use containerd or CRI-O directly

### Current Options

| Runtime | Description | When to Use |
|---------|-------------|-------------|
| **containerd** | Docker's core runtime | Most common, stable |
| **CRI-O** | Built for Kubernetes | Red Hat systems |

Both implement CRI (Container Runtime Interface) - standard interface for kubelet communication.

---

## 🧹 Cleaning Previous Installations

### Complete Cleanup Process

```bash
# 1. Check what's installed
minikube status
minikube profile list
docker ps -a | grep -E "minikube|kube"

# 2. Stop everything
minikube stop

# 3. Delete minikube cluster
minikube delete --all --purge

# 4. Clean configuration
rm -rf ~/.minikube
rm -rf ~/.kube

# 5. Remove kubectl context
kubectl config delete-context minikube
kubectl config delete-cluster minikube

# 6. Remove binaries (optional)
sudo rm $(which minikube)
sudo rm $(which kubectl)

# 7. Verify cleanup
docker ps -a
docker images
kubectl get nodes  # Should fail
```

---

## 🚀 Fresh Minikube Installation

### Prerequisites Check

```bash
# Check virtualization support
grep -E --color 'vmx|svm' /proc/cpuinfo

# Check architecture
uname -m  # Should be x86_64 or aarch64
```

### Step 1: Install Docker (as Minikube driver)

```bash
# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Test
docker run hello-world
```

### Step 2: Install kubectl

```bash
# Download latest kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
kubectl version --client
```

### Step 3: Install Minikube

```bash
# Download
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify
minikube version
```

### Step 4: Start Your Cluster

```bash
# Start with Docker driver
minikube start --driver=docker

# Check status
minikube status

# Verify kubectl connection
kubectl get nodes

# See running pods
kubectl get pods -n kube-system

# Access the cluster
minikube ssh
# Inside: docker ps (to see K8s components)
# Exit: exit
```

---

## 📚 Key Learning Points

### Understanding vs Copy-Paste

1. **Don't rush** - Understand each component's purpose
2. **Check outputs** - Read what each command returns
3. **Explore inside** - Use `minikube ssh` to see internals
4. **Break things** - Best way to learn is experimentation

### What Happens When Minikube Starts

1. Downloads Kubernetes Docker image
2. Creates Docker container as "node"
3. Runs all K8s components inside container
4. Configures kubectl to connect to this cluster

### Minikube vs Real Cluster

| Aspect | Minikube | kubeadm Cluster |
|--------|----------|-----------------|
| Nodes | Single | Multiple |
| Networking | Simplified | Real CNI |
| Storage | Basic | Configurable |
| Learning | Basics | Production-ready |

---

## 🎓 Next Steps

1. **Deploy first app**: Create a simple nginx deployment
2. **Expose with Service**: Learn ClusterIP, NodePort, LoadBalancer
3. **Scale and update**: Practice rolling updates
4. **Add persistence**: Work with PersistentVolumes
5. **Move to kubeadm**: Build multi-node cluster on remaining servers

---

## 🔍 Troubleshooting Tips

| Problem | Solution |
|---------|----------|
| kubectl connection refused | Check `minikube status`, restart if needed |
| Docker permission denied | Add user to docker group: `sudo usermod -aG docker $USER` |
| Pods not starting | Check logs: `kubectl logs <pod-name> -n <namespace>` |
| Out of resources | Adjust: `minikube config set memory 4096` |

---

## 📖 Understanding Over Memorization

Remember: The goal is to understand **why** each step is needed, not just memorize commands. Each component has a specific purpose in the Kubernetes ecosystem.

**Golden Rule**: If you don't understand why you're running a command, stop and research it first.