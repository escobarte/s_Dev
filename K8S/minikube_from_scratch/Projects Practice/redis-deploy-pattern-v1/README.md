# Steps that you should in ubuntu terminal to do to see the result

### Aplly config 
### Apply main

*Check pods availability and do test ping iside the container*
```
kubectl get pods -n production
#redis-cache-7d74cccd5d-vclhs          1/1     Running   0          18s

kubectl exec -n porduction redis-cache-7d74cccd5d-vclhs -- redis-cli ping
#PONG

