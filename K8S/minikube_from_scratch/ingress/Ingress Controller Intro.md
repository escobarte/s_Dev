# Ingress Controller aka NGINX on manual

```
✅ Host-based routing (different domains → different services)
✅ Path-based routing (same domain, different paths → different services)
✅ URL rewriting (strip path prefixes)
```
**Remove the path prefix before forwarding to backend**

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
```sh
kubectl apply -f ingress-path-demo.yaml
kubectl get ingress -n production
```
```
# Test routing
curl -H "Host: app1.local" http://$(minikube ip)
curl -H "Host: app2.local" http://$(minikube ip)
curl -H "Host: myapp.local" http://$(minikube ip)/web
curl -H "Host: myapp.local" http://$(minikube ip)/api
```

**ingress-path-demo.yaml**
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: app2
            port:
              number: 80
```

## Ingress Practice Exercise 1: WordPress with Multiple Services
```
# Deploy WordPress (you already have this, but let's create fresh in production)
kubectl create deployment wordpress --image=wordpress:latest --replicas=2 -n production
kubectl expose deployment wordpress --port=80 -n production

# Deploy a simple API (we'll use httpbin for testing)
kubectl create deployment api --image=kennethreitz/httpbin --replicas=2 -n production
kubectl expose deployment api --port=80 -n production

# Verify both are running
kubectl get all -n production | grep -E "wordpress|api"
```
**Your Task: Create Ingress**
```sh
Create wordpress-ingress.yaml that routes:

blog.mycompany.local/ → wordpress service (port 80)
blog.mycompany.local/api/ → api service (port 80)
Add rewrite annotation to strip /api prefix

Requirements:

Use single hostname: blog.mycompany.local
Path / goes to WordPress
Path /api goes to API service
Add proper URL rewriting for the API path

Write the complete ingress YAML yourself, then test with:
```

wordpress-ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-ingress
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2   # Используем $2 чтобы удалить префикс /api
    nginx.ingress.kubernetes.io/use-regex: "true"     # Включаем поддержку регулярных выражений
spec:
  ingressClassName: nginx        # Зависит от твоего ingress controller, может быть "nginx"
  rules:
  - host: blog.mycompany.local   # Один хост для всего приложения
    http:
      paths:
      - path: /api(/|$)(.*)      # Совпадает с /api и любым путём после него
        pathType: ImplementationSpecific
        backend:
          service:
            name: api
            port:
              number: 80
      - path: /()(.*)            # Все остальные пути (/) идут в WordPress
        pathType: ImplementationSpecific
        backend:
          service:
            name: wordpress
            port:
              number: 80
```


**Simple Ingress Exercise 2: Two Static Websites**
Your Task - Create Ingress
Create sites-ingress.yaml with host-based routing (simple, no regex):
marketing.local → site1 service
support.local → site2 service
```yaml
# Create ConfigMaps with different content
kubectl create configmap site1-content --from-literal=index.html='<h1>Site 1 - Marketing Page</h1>' -n production

kubectl create configmap site2-content --from-literal=index.html='<h1>Site 2 - Support Page</h1>' -n production

# Deploy nginx with custom content
kubectl create deployment site1 --image=nginx --replicas=1 -n production
kubectl create deployment site2 --image=nginx --replicas=1 -n production

# Mount the ConfigMaps (we'll use kubectl patch)
kubectl patch deployment site1 -n production --patch '
spec:
  template:
    spec:
      containers:
      - name: nginx
        volumeMounts:
        - name: content
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: content
        configMap:
          name: site1-content
'

kubectl patch deployment site2 -n production --patch '
spec:
  template:
    spec:
      containers:
      - name: nginx
        volumeMounts:
        - name: content
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: content
        configMap:
          name: site2-content
'

# Expose both
kubectl expose deployment site1 --port=80 -n production
kubectl expose deployment site2 --port=80 -n production
```
**site-ingress.yaml**
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-routing
  namespace: production
spec:
  rules:
  - host: marketing.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: site1
            port:
              number: 80
  - host: support.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: site2
            port:
              number: 80
```

