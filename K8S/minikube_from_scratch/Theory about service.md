# Any time you want to access pods or allow pods to talk to each other, you need a Service

## **When You Need to Create Services**

**Simple rule:** Any time you want to access pods or allow pods to talk to each other, you need a Service.

## **Common Scenarios:**

### **1. External Access (from outside Kubernetes)**
```
You need to access pods from browser/curl
→ Create Service with type: NodePort or LoadBalancer
```

**Examples:**
- Web applications (WordPress, nginx)
- APIs you want to call
- Databases you connect to from outside cluster

### **2. Internal Communication (pod-to-pod)**
```
One pod needs to talk to another pod
→ Create Service with type: ClusterIP
```

**Examples:**
- WordPress → MySQL (what you just did)
- Frontend → Backend API
- App → Redis cache

### **3. When Pods Restart**
```
Pods get new IPs when they restart
→ Service gives stable DNS name
```

Without Service, WordPress would need to know MySQL's exact IP (which changes).
With Service, WordPress just uses `mysql-service` (never changes).

## **The Pattern You'll Always Use:**

```yaml
Deployment (creates pods) + Service (exposes pods) = Working application
```

## **Your Current Architecture:**

```
wordpress-app deployment (2 pods) ← wordpress-service (NodePort) ← Your browser
         ↓
    mysql-service (ClusterIP)
         ↓
mysql-database deployment (1 pod)
```

**Summary:** Create a Service whenever pods need to be reached - either from outside the cluster or by other pods inside the cluster.

Does this clarify when Services are necessary?