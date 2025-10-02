# Minikube from Zero to Hero
## Practice book

**Today I created by myself (almost) the next structre**
*Wordpress -> Mysql_DB*
```
**Theory**
Every pod needs its own network config, called as Service.
I created: 
2 Deploymens (wordpress && db)
2 Services:
	wodpress-servive: NodePort (for internal use only)
	db-service: ClusterIP (external)
```
*First i created db*
**1. mysql-db.yaml**
**Don't forget to create a DATA BASE in mysql**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-database
spec:
  replicas: 1
  selector:
    matchLabels:
      db: mysql
  template:
    metadata:
      labels:
        db: mysql
    spec:
      containers:
      - name: mysql-database
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "passwd123"
        - name: MYSQL_DATABASE
          value: "wordpress"
```

**2. wordpress.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress-app
  labels:
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress-app
        image: wordpress:latest
        ports:
        - containerPort: 80
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql-service
        - name: WORDPRESS_DB_USER
          value: root
        - name: WORDPRESS_DB_PASSWORD
          value: passwd123
        - name: WORDPRESS_DB_NAME
          value: wordpress
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```


**3. wp-service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress-service
spec:
  selector:
    app: wordpress
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
```


**4. mysql-service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    db: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
```