## **Practice Exercise: Elasticsearch Search Engine**

Deploy Elasticsearch with proper security and configuration.

---

### **Task 1: Create Secret**

Create `elasticsearch-secrets.yaml` in the `production` namespace with these credentials:

- Elastic superuser password
- Kibana system user password  
- Cluster name

Choose appropriate key names yourself and secure passwords.

---

### **Task 2: Create ConfigMap**

Create `elasticsearch-config.yaml` with basic Elasticsearch configuration:

- Set discovery type to single-node
- Set cluster name from environment
- Disable X-Pack security for learning purposes
- Set network host to 0.0.0.0

---

### **Task 3: Create Deployment**

Create `elasticsearch-deployment.yaml`:

- Name: `elasticsearch`
- Namespace: `production`
- Labels: `app: elasticsearch`, `tier: search`
- Replicas: 1
- Image: `elasticsearch:8.11.0`
- Port: 9200
- Environment variables:
  - `ELASTIC_PASSWORD` from secret
  - `discovery.type=single-node` (hardcoded)
  - `xpack.security.enabled=false` (hardcoded)
- Mount ConfigMap to: `/usr/share/elasticsearch/config/elasticsearch.yml`
- Resources: requests 512Mi/500m, limits 1Gi/1000m
- Liveness probe: HTTP GET to `/_cluster/health` on port 9200
  - initialDelaySeconds: 60, periodSeconds: 10

---

### **Task 4: Create Service**

Create `elasticsearch-service.yaml`:

- ClusterIP service on port 9200

---

**Your turn.** Create all 4 files yourself. Show me your work when done.