# Deployment with Resource Limits and Health Checks
**production-ready deployment with proper resource management and health monitoring:**

### Theory
**Difference between "Livness"(жизнеспособность) and "Readiness"(готовность) probes**
```
Leavness Probe: Is container alive?
	1. Fails -> Restart the conteiner (Use Case: Detect deadlock, hung processes)

Readiness Probe: Is the container ready to receive traffic?
	1. Fails -> Remove from service
	2. Passes -> Add back to service (Use Case: App is starting up, warming cache, loading data)
```

**Health Probes: Essential Production Concept**
*Yes, this is fundamental for any production Kubernetes work. Let me explain why:*
What This Block Does
```yaml
httpGet:
  path: /              # Check this URL endpoint
  port: 80             # On this port
initialDelaySeconds: 10  # Wait 10s after container starts
periodSeconds: 5         # Check every 5 seconds
```
```
Translation: "Every 5 seconds, make an HTTP GET request to http://container:80/. If it returns 200-399 status code = healthy. Otherwise = unhealthy."
Why This Matters in Real Work
Without Health Probes:
Container crashes internally → Process still running → Kubernetes thinks it's fine → Users get errors
With Health Probes:
Container stops responding → Probe fails → Kubernetes restarts it → Service restored
```

### Real Production Scenarios
**Scenario 1: Database connection lost**
```
App can't connect to DB but container is running
Without probe: App stays broken, users get 500 errors
With probe: Kubernetes detects failure, restarts container, reconnects to DB
```
**Scenario 2: Memory leak**
```
App consumes all memory, becomes unresponsive
Without probe: App hangs forever
With probe: Liveness fails, Kubernetes restarts, fresh start
```
**Scenario 3: Slow startup**
```
App takes 30 seconds to initialize
Without readiness probe: Traffic sent immediately, users get errors
With readiness probe: No traffic until app is ready
```
```
Standard Practice
Every production deployment should have:
Liveness probe - restart if dead
Readiness probe - control traffic flow
Resource limits - prevent resource exhaustion
```
**You'll use this pattern in 95% of deployments. It's not optional in professional environments.**

## Example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-production
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
      tier: frontend
  template:
    metadata:
      labels:
        app: nginx
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"      # Fill in: minimum memory needed
            cpu: "100m"         # Fill in: minimum CPU needed
          limits:
            memory: "128Mi"      # Fill in: maximum memory allowed
            cpu: "200m"         # Fill in: maximum CPU allowed
        livenessProbe:          # Checks if container is alive
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10  # How long to wait before first check
          periodSeconds: 5         # How often to check
        readinessProbe:         # Checks if container is ready for traffic
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
```