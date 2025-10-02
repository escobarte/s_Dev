# Minikube from Zero to Hero

**Prepare LVM disk**
```
you know how to do it
sudo chown -R scusnir:scusnir /var/lib/minikube
```

**Install Minikube and Kubectl***
```sh
# 1. Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# 2. Verify installation
minikube version

# 3. Install kubectl (Kubernetes CLI)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl
rm kubectl

# 4. Verify kubectl
kubectl version --client
```

**Configuration Minikube**
**IMPORTANT: TO NOT DO FROM SUDO, DO FROM SIMPLE USER**
```sh
# 1. Add your user to docker group (run this as your regular user)
sudo usermod -aG docker $USER

# 2. Apply the group changes immediately
newgrp docker

# 3. Verify Docker access works now
docker ps

# 4. Test docker command without sudo
docker version
```

```sh
# 1. Set Docker as the default driver
minikube config set driver docker

# 2. Configure resource allocation (conservative but sufficient)
minikube config set memory 2048
minikube config set cpus 2

# 3. Set custom storage location to use your dedicated volume
# Set the environment variable (temporary)
export MINIKUBE_HOME=/var/lib/minikube
# Make it permanent by adding to your profile
echo 'export MINIKUBE_HOME=/var/lib/minikube' >> ~/.bashrc
# Reload your shell environment
source ~/.bashrc
# Verify it's set
echo $MINIKUBE_HOME
# Now start Minikube (it will use the new location)
minikube start --driver=docker


# 4. Verify your configuration
minikube config view
```

**Let's verify cluster**
```sh
# 1. Check cluster status
minikube status

# 2. Verify kubectl is connected
kubectl cluster-info

# 3. See the nodes in your cluster
kubectl get nodes

# 4. Check system pods (Kubernetes components)
kubectl get pods -n kube-system

# 5. Verify storage is using your dedicated volume
df -h /var/lib/minikube
```
**Basic exploration commands**
```sh
# See all namespaces (organizational units)
kubectl get namespaces

# Check what's running in default namespace (empty for now)
kubectl get all

# Get more details about your node
kubectl describe node minikube
```


# Definitions:
```
Your system now has:

Control plane: API server, scheduler, etcd (database)
Worker node: Where your applications will run
Container runtime: Docker managing your containers
Network: CNI bridge for pod communication
Storage: Default storage class for persistent volumes

What You Actually Built
Think of Kubernetes like a smart apartment building manager. You just hired this manager (Kubernetes) to run your building (server). Let's break down what you're seeing:
1. Your "Building Manager" Status
Name: minikube
Roles: control-plane
Ready: True
This means:

Name: Your manager is called "minikube"
Role: It's both the "control-plane" (the brain making decisions) AND the worker (doing the actual work)
Ready: The manager is awake and working

2. Building Capacity (What Your Server Can Handle)
Capacity:
  cpu: 4 cores
  memory: 3960992Ki (about 3.8GB)
  pods: 110 (maximum 110 applications)
Translation: Your server can run up to 110 small applications simultaneously.
3. Current Residents (System Services Already Running)
Non-terminated Pods: (7 in total)
- coredns: Phone book service (helps apps find each other)
- etcd: Database (remembers everything)
- kube-apiserver: Reception desk (receives all requests)
- kube-controller-manager: Building supervisor
- kube-proxy: Mail service (routes messages)
- kube-scheduler: Decides which apartment (server) gets new residents
- storage-provisioner: Storage room manager
```

**kubectl get pods -o wide**

# Practice, first 
**Creating simple pod web server**
```sh
# Creating simple pod web server
kubectl run web-app-01 --image=nginx --port=80
# Wait 30-40 sec, for Container Creating
kubectl get pods
# Now let's create a "Service" like opening dor for this web serve
kubectl expose pod web-app-01 --type=NodePort --port=80
kubectl get services # we-app-01    NodePort    10.105.95.187   <none>        80:30181/TCP   61s
# To see what is the IP address of minikube kluster
minikube ip
curl http://192.168.49.2:30181
# If you want to check it external, on browser
kubectl port-forwad --address 0.0.0.0 pod/web-app-01 8084:80
```

**Deleting Pod and see what happend**
```sh
kubectl delete pod web-app-01
kubectl get	pods # nothing
```
**If you want delete, and you don't know is this a service or deployment, here are the commands to check**
*SO, when you found what is, you just delete what needed (kubectl delete service)*
```sh
kubectl get all
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get replicasets
```

**Creating Replica set Called Deployment**
```sh
kubectl create deployment web-app-02 --image=nginx --replicas=3
kubectl get deployment
# if you will delete one of the pods, it will be recreated automated
```
**Scaling pods + Expose**
```sh
kubectl expose deployment web-app-02 --port=80 --type=NodePort
kubectl get services
curl http://192.168.49.2:30753
#Scale Up and Down
kubectl scale deployment/web-app-02 --replicas=5 # Was 3 adde +2
kubectl scale deployment/web-app-02 --replicas=3 # Was 5 removed 2
```
# Upgrading "image" NGINX to other version in pod
**First took actual information **
```sh

kubectl describe deployment/my-web-app | grep Image
# Image:         nginx

**OR**

kubectl describe pod web-app-02-78559956bf-8tzhm 
# Result
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:d5f28ef21aabddd098f3dbc21fe5b7a7d7a184720bc07da0b6c9b9820e97f25e
  	Normal  Pulled     8m43s  kubelet            Successfully pulled image "nginx" in 1.215s Image size: 192385289 bytes.

**OR**
kubectl exec web-app-02-78559956bf-8tzhm -- nginx -v # nginx/1.29.1
# Get into the pod
kubectl exec -it web-app-02-78559956bf-8tzhm -- /bin/bash
nginx -v #  nginx/1.29.1
```
**Apply upgades**
```sh
kubectl rollout history deployment/web-app-02 #history
kubectl rollout status deployment/web-app-02

kubectl set image deployment/web-app-02 nginx=nginx:1.21
kubectl exec web-app-02-7f94549b7-5mqdh -- nginx -v # Result: nginx/1.21.6

#Revert or Undo 
kubectl rollout undo deployment/web-app-02
```

# Kubernetes VOLUMES (persistent storage) - Using proper YAML files 
## Create a workspace for .yaml files, use home directory to not have issues with rights
```sh
mkdir -p ~/k8s-learning && cd ~/k8s-learning
```
**Create Storage**
`vi pvc.yaml`
```bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: storage-web-app-03
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

`vi deploy-nginx-with-storage.yaml`
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-03
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-storage
  template:
    metadata:
      labels:
        app: nginx-storage
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: web-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: web-content
        persistentVolumeClaim:
          claimName: storage-web-app-03
  ```

  **Execution Steps**
  ```sh
kubectl apply -f pvc.yaml # to create this storage
kubectl apply -f deploy-nginx-with-storage.yaml # deploy 2 pods
kubectl get pods --show-labels
kubectl get deployments
```

**Testing Persistant Storage**
```sh
#Entering into pod
kubectl port-forward --address 0.0.0.0 deployments/web-app-03 8085:80
echo "<h1>This data should survive pod restart!</h1>" > /usr/share/nginx/html/index.html
echo "Created at: $(date)" >> /usr/share/nginx/html/index.html
exit
# 3. Create service to access it
kubectl expose deployment web-app-03 --port=80 --type=NodePort
# Delete pod
kubectl delete pod web-app-03-86d8946b4d-8cps5
#Information remained. All good


