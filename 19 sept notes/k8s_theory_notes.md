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