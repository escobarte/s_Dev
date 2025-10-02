
------------------------------------------------------------------------------
# mysql-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: production
data:
  my.cnf: |
    [mysqld]
    max_connections=200
    character-set-server=utf8mb4
    collation-server=utf8mb4_unicode_ci
    default-time-zone='+00:00'
-------------------------------------------------------------------------------
# mysql-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secrets
  namespace: production
type: Opaque
stringData:
  root-password: SuperSecret123
  database: appdb
  user: appuser
  password: AppPassword456
--------------------------------------------------------------------------------
# mysql-service.yaml
apiVersion: v1
kind:service
metadata:
  name:mysql-service
  namespace: database
spec:
  selector:
    app: mysql
    tier: database
  ports:
  - port: 3306
    targePort: 3306
  type: ClusterIP
-----------------------------------------------------------------------------

# mysql-main.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-database
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
      tier: database
  template:
    metadata:
      labels:
        app: mysql
        tier: database
    spec:
      containers:
      - name: mysql-database
        image: mysql:8.0
        ports:
        - containerPort: 3306
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/mysql/conf.d/my.cnf
          subPath: my.cnf
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secrets
              key: root-password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-secrets
              key: database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secrets
              key: user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secrets
              key: password
        livenessProbe:
          exec:
            command: ["mysqladmin", "ping", "-h", "localhost"]
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command: ["mysqladmin", "ping", "-h", "localhost"]
          initialDelaySeconds: 30
          periodSeconds: 10
      volumes:
      - name: config-volume
        configMap:
          name: mysql-config

