# Ingress Controller aka NGINX on manual

```
Internet → Ingress Controller (port 80) → Routes traffic:
  ├─ blog.local/ → wordpress-service
  ├─ api.local/  → api-service
  └─ db.local/   → database-service
 ```

### Enabling Ingress Controller
```sh
minikube addons enable ingress
kubectl get pods -n ingress-nginx # or watch kubectl get pods -n ingress-nginx
```
*The Result*
```sh
NAME                                       READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-pj458       0/1     Completed   0          2m1s # Patched webhook configs
ingress-nginx-admission-patch-dbrtw        0/1     Completed   1          2m1s # Created webhook configs
ingress-nginx-controller-9cc49f96f-hfhp9   1/1     Running     0          2m1s # Main Ingress Controller
```

### Creating some simple deployments to demonstrate routing
**Creating Deploys**
```sh
# Create app1
kubectl create deployment app1 --image=nginx --replicas=1 -n production
kubectl expose deployment app1 --port=80 -n production

# Create app2  
kubectl create deployment app2 --image=httpd --replicas=1 -n production
kubectl expose deployment app2 --port=80 -n production

# Verify both are running
kubectl get all -n production
```

**myfirst-ingress-demo.yaml**
```sh
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
  namespace: production
spec:
  rules:
  - host: app1.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
  - host: app2.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2
            port:
              number: 80
```
*Check the results*
```
kubectl apply -f ingress-demo.yaml
kubectl get ingress -n production

# Test routing
curl -H "Host: app1.local" http://$(minikube ip)
curl -H "Host: app2.local" http://$(minikube ip)
curl -H "Host: myapp.local" http://$(minikube ip)/web
curl -H "Host: myapp.local" http://$(minikube ip)/api
```

