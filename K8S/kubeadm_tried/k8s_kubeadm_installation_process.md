# Kubernetes installation on 93.5

Creating dedicated LVM setup
    ```
    parted /dev/sdb print free
    fdisk /dev/sdb
    pvcreate /dev/sdb8
    vgcreate vg_kuber /dev/sdb8
    lvcreate -n netes -l 5887 vg_kuber
    mkfst.ext4 /dev/mapper/vg_kuber-netes
    mkdir -p /opt/kubernetes/{kubelet,containered,etcd}
    mount /dev/mapper/vg_kuber-netes /opt/kubernetes
    vi /etc/fstab
    /dev/mapper/vg_kuber-netes /opt/kubernetes/ ext4 defaults 0 2
    mount -a
    ```

Install and configure containerd
Prerequisition information:

```
└─sdb8                   8:24   0   23G  0 part
  └─vg_kuber-netes     252:8    0   23G  0 lvm  /opt/kubernetes
This will be for data for specific folders (kubelet, containerd, etcd)

/var/lib/docker/ = 492M <before kubernetes practice>
```

## Step 1: "containerd" Installation and configuration

```
# Add Docker repository, update and install
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

apt update && apt install -y containerd.io

#Configuration (modify config storage to use)
## Generate & Edit 

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
vi /etc/containerd/config.toml
# change `root = "/var/lib/containerd"` --> `root = "/opt/kubernetes/containerd"`

systemctl restart containerd
systemctl enable containerd
systemctl status containerd
```

## Step 2: "kubernetes kubeadm" Installation and Configuration

```
#Adding kuber repo, install, hold automatic updates change configuration storage

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo 'Environment="KUBELET_EXTRA_ARGS=--root-dir=/opt/kubernetes/kubelet"' | sudo tee /etc/systemd/system/kubelet.service.d/20-root-dir.conf

systemctl daemon-reload
```

## Step 3: Initializeing the Control Plane (ONLY)

**Issue Meet with Swap**

```
swapoff -a
vi /etc/fstb (# for swap)
rm -f /swap.img
free -h
```

**Complete RESET**

```
# Stop kubelet
sudo systemctl stop kubelet

# Reset kubeadm completely
sudo kubeadm reset -f --cleanup-tmp-dir

# Clean up any remaining containers
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock rm -f $(sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -aq) 2>/dev/null || true

# Clean up networking
sudo rm -rf /etc/cni/net.d/*
sudo rm -rf /var/lib/cni/
```

**Check basic prerequisites**

```
# Verify swap is really off
free -h
cat /proc/swaps

# Check if containerd is working
sudo systemctl status containerd

# Test containerd
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version
```

## Step 4: Set up "kubectl access" on control plane

**4.1** Setup fo your user

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**4.2** **Minimal Start**

```
# Simple init without extra parameters first
sudo kubeadm init --v=5

#Join command for later:
kubeadm join 10.100.93.5:6443 --token scsi9j.9m7s5k81x3xk5dbg \
        --discovery-token-ca-cert-hash sha256:5f2286b9d486f76143ff3eb329c42670d0a75312a981236515fb91ba35827fb2
```

**The Gold of debugg**

```
# Check static pods in manifests directory
ls -la /etc/kubernetes/manifests/

# Check container runtime
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a
```

## Setup cubectl access && metwoek plugin (Flannel)

```bash
# Install Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Wait a moment, then check if pods are starting
kubectl get pods -n kube-flannel
kubectl get pods -n kube-system

# Check if node becomes Ready (may take 1-2 minutes)
kubectl get nodes -o wide
```

## Step 5: Properly configure custom storage

**During the trebouleshooting, I reveret to default paths, not mine created on /opt/kubernetes. When i tried to run API server, it is crashing because of it's running out of space on OS-root. Now, i will move it on my LVM**
**A. Stop kubelet and check data**

```bash
systemctl stop kubelet
kubeadm reset -f -cleanup-tmp-dir
rm -rf /var/lib/etcd /var/lib/kubelet
rm -rf /etc/kubernetes/manifests/*
rm -rf /etc/cni/net.d/*
```

```bash
chown -R root:root /opt/kubernetes/
chmod -R 755 /opt/kubernetes/
---- Remove Data---
sudo kubeadm reset -f --cleanup-tmp-dir

# Remove all existing data
sudo rm -rf /var/lib/etcd /var/lib/kubelet
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf /etc/cni/net.d/*

# Create bind mounts to redirect default paths to your custom storage
sudo mkdir -p /var/lib/kubelet /var/lib/etcd
echo "/opt/kubernetes/kubelet /var/lib/kubelet none bind 0 0" | sudo tee -a /etc/fstab
echo "/opt/kubernetes/etcd /var/lib/etcd none bind 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# Verify mounts
df -h | grep "/var/lib"

# Stop kubelet
sudo systemctl stop kubelet

# Remove existing kubelet certificates and config
sudo rm -f /var/lib/kubelet/pki/kubelet-client*
sudo rm -f /etc/kubernetes/kubelet.conf

# Regenerate kubelet certificates using kubeadm
sudo kubeadm init phase kubeconfig kubelet

# Start kubelet
sudo systemctl start kubelet

# Wait and check
sleep 20
kubectl get nodes
```

## Step 6: Installing **WORKER NODE**

```bash
# Update and basic setup
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gpg

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install containerd (same as before)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list


# Add Kubernetes repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and install
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Hold packages to prevent updates
sudo apt-mark hold kubelet kubeadm kubectl

sudo apt update
sudo apt install -y containerd.io

# Configure containerd (default config is fine for now)
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

**DO Tests Verification**

```bash
# Now crictl should work
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version

# Test image pull
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock pull registry.k8s.io/pause:3.10

# Check versions
kubelet --version
kubeadm version


# Can reach control plane?
ping -c 3 10.100.93.5

# Can reach API server port?
nc -zv 10.100.93.5 6443
```