# ConfigMaps & Secrets

**ConfigMap for Database Settings**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-config
data:
  DB_HOST: mysql-service
  DB_NAME: wordpress
  DB_USER: root
```

**Secrects for Database**
```yaml
apiVersion: v1
kind: Secret
metadata
  name: databes-secret
type: Opaque
stringData:
  DB_PASSWORD: passwd123
```

**Update wordpress.yaml configuraion with ConfigMap Variables**
*env line*
```yaml
env:
- name: WORDPRESS_DB_HOST
  valueFrom:
    configMapKeyRef:
      name: database-config
      key: DB_HOST
- name: WORDPRESS_DB_NAME
  valueFrom:
    configMapKeyRef:
      name: database-config
      key: DB_NAME
- name: WORDPRESS_DB_USER
  valueFrom:
    configMapKeyRef:
      name: database-config
      key: DB_USER
- name: WORDPRESS_DB_PASSWORD
  valueFrom:
  	secretKeyRef:
  	  name: databes-secret
  	  key: DB_PASSWORD
```

## Now Apply Updates, Force Restarts, Verify, Browser Check
```sh
##1##
kubectl apply -f database-config.yaml
kubectl apply -f database-secret.yaml
kubectl get secrets
kubectl apply -f wordpress.yaml

##2##
kubectl rollout restart deployment wordpress-app

##3##
kubectl exec -it wordpress-app-7fcd6d8bfb-6lt7m -- env | grep WORDPRESS_DB

##4## Check in browser
kubectl port-forward --address 0.0.0.0 deployment/wordpress-app 8088:80

```
