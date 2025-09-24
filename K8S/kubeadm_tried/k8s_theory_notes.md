**Flannel** is a **Container Network Interface (CNI) plugin** for Kubernetes that provides networking between pods across different nodes in a cluster.

## What Flannel Does

Flannel creates a **virtual overlay network** that allows pods on different nodes to communicate with each other. It assigns each node a subnet from a larger network range and ensures packets can route between pods regardless of which physical node they're running on.

## How It Works

1. **IP Address Management**: Flannel assigns each node a unique subnet (like 10.244.1.0/24, 10.244.2.0/24)
2. **Packet Encapsulation**: When a pod needs to talk to a pod on another node, Flannel wraps the packet and sends it through the overlay network
3. **Routing**: It maintains routing tables so traffic knows how to reach pods on other nodes

## Key Features

- **Simple setup** - Easy to deploy and configure
- **Multiple backends** - VXLAN (most common), host-gw, UDP
- **Cross-platform** - Works on Linux, Windows
- **Lightweight** - Minimal resource overhead

## Common Use Cases

- **Basic Kubernetes networking** when you need simple pod-to-pod communication
- **Multi-node clusters** where pods need to communicate across physical machines
- **Development/testing environments** due to its simplicity

## Installation

Typically deployed as a DaemonSet:

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

Flannel is one of several CNI options (others include Calico, Weave, Cilium) but remains popular for its simplicity and reliability.



------------------------------------------------------------------------------------------------

Types of kuber:

1. minikube (Master and Workers on the same environment) - good for local env, study, tests
2. kubeadm (Production-like cluster, real arhitecture Kubernetes, possibility of HA, practice for real sotrage and network models)
3. 

------------------------------------------------------------------------------------------------

Kubernetes - written on GO
For: 
Автоматизация контейнеров - Развёртывание, Масштабирование, Управление.
--- K8s 
Основной компонент = Cluster состоящий из Nodes

1. Worker Nodes = сервера на котором запускаются и работают конейнеры
2. Master Nodes = главный сервер который управляет Worker Nodes

--- Master Node = 3 main process k8s

* kube-apiserver
* kuber-controller-manager
* kube-scheduler
  --- Worker Node = 2 main process k8s
* kubelet
* kube-proxy

6 Main Aspects

1. Service discovery and load balancing
2. Storage orchestration (Automatically mount a storage system of your choice)
3. Automated rollouts and rollbacks (Automatic do update to Docker image or other)
4. Automatic bin packing (You tell k8s how much CPU and RAM each container needs, and it can fit containers onto you nodes to make the best use of your resources)
5. Self-healing (Restart, Replace, kills)
6. Secret and configuration management

---------------------------------------------------------------------------------------

minikube status
kubectl get pods -A
kubectl getg nodes
kubectl config view
kubectl config current-context
docker ps | grep minikube # Проверим, использует ли minikube Docker
docker system df # Проверяем, что Docker чист (если используешь Docker)

# Проверяем, что нет остатков пакетов k8s

dpkg -l | grep -E "kube|k8s"     # для Debian/Ubuntu
rpm -qa | grep -E "kube|k8s"      # для RHEL/CentOS
wchich kubectl
whicth minikube
ps aux | grep minikube

-----------------------

uname -a