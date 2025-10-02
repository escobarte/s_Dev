# Namespaces

`kubectl get namespaces`
```sh
NAME              STATUS   AGE
default           Active   6d		# where all your resources are now
kube-node-lease   Active   6d		# used by Kubernetes for node heartbeat/lease management.
kube-public       Active   6d		# Kubernetes internal components
kube-system       Active   6d		# pulicly accessible data
```
```
Why Use Namespaces?
Imagine a company with:

Development team testing new features
Staging environment for pre-production
Production serving real users

Without namespaces: Everything mixed together, accidental deletions, resource conflicts.
```

# Namespace Practice Exercises
**Let's create and explore**
```
kubectl create namespace development
kubectl create namespace production

kubectl get all -n defaul #(all resources that i did before)
kubectl get all -n development #(no resources)
kubectl get all -n production #(the same, no resources)
```

**Deploy some App in Different Namespace**
*1 will be for dev* *1 will be for prod*
**ngix-dev.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  namespace: development
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
      env: dev
  template:
    metadata:
      labels:
        app: nginx
        env: dev
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 81 
```
**nginx-prod.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
      env: prod
  template:
    metadata:
      labels:
        app: nginx
        env: prod
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 81 
```

**Applying and Comparing**
```sh
kubectl apply -f k8s-learning/nginx-dev.yaml
kubectl apply -f k8s-learning/nginx-prod.yaml
# to see them in pods
kubectl get pods -n development
kubectl get pods -n production

```

**Working across Namespaces**
```yaml
# Change defaul namespace, other one created by you
kubectl config set-context --current --namespace=development
kubectl config set-context --current --namespace=production
kubectl config set-context --current --namespace=default
```

**Delete Namespaces**
```
kubectl delete namepsace development
```