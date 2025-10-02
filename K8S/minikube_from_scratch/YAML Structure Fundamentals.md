# YAML Structure Fundamentals
**Every Kubernetes YAML has these 4 required fields:**

```sh
apiVersion: v1 				#Which Kubernetes API to use
kind: Pod/Deployment		#What type of resources (chose only one)
metadata:					#Information about the resources
	name: web-db-01
spec:						#The DESIRED state/configuration
	# .... to be continued
```

# Apache Web Server Example - Human-Readable Names
```yaml
# apache-webserver.yaml
apiVersion: apps/v1                          # Kubernetes API version for Deployments
kind: Deployment                             # Resource type: Deployment
metadata:
  name: company-website                      # Human-readable: our company website
  labels:                                    # Labels for this deployment
    project: corporate-site                  # Project name
    tier: frontend                          # Application tier
    owner: web-team                         # Team responsible
spec:                                       # Deployment configuration
  replicas: 3                              # Run 3 copies for high availability
  selector:                                # How to find pods belonging to this deployment
    matchLabels:
      component: web-frontend              # Look for pods with this label
      service: company-website             # And this label
  template:                               # Pod template - blueprint for creating pods
    metadata:
      labels:                             # Labels to put on each pod
        component: web-frontend           # Same as selector above
        service: company-website          # Same as selector above
        version: v2.1                     # Version for tracking
    spec:                                 # Pod specification
      containers:                         # List of containers in each pod
      - name: apache-server               # Container name (human-readable)
        image: httpd:2.4                  # Apache HTTP Server image
        ports:
        - containerPort: 80               # Port Apache listens on
          name: http-port                 # Name the port for clarity
        resources:                        # Resource limits/requests
          requests:                       # Minimum resources needed
            memory: "128Mi"               # 128 megabytes RAM
            cpu: "250m"                   # 0.25 CPU cores
          limits:                         # Maximum resources allowed
            memory: "256Mi"               # 256 megabytes RAM max
            cpu: "500m"                   # 0.5 CPU cores max
```