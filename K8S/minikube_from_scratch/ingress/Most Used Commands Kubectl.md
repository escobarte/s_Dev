**Most Used and Popular commands**
```sh
kubectl get all -n production # Shows all kinds?
kubectl delete ingress <name> path-based-ingress -n production # It will delete it
```


**Task Manager for Kubernetes**
```
minikube addons enable metrics-server #wait 60-90 sec
kubectl top pods
kubectl top pods -n production
kubectl top nodes 							# TOP
kubectl top pods -l app=nginx
kubectl describe pods -n production | grep -A 5 "Limits\|Requests"  							# TOP
watch kubectl top pods 							# TOP
watch kubectl top pods --containers
kubectl top pods -A  							# TOP
```

**Ingress aka Nginx activating**
```sh
minikube addons enable ingress
kubectl get pods -n ingress-nginx # or watch kubectl get pods -n ingress-nginx
```
