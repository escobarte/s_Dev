## nginx-config.yaml
```
Здесь прописан тот сам конфиг для nginxa, то есть та саммая информация которая лежит по пути /etc/nginx/nginx.conf. Получается мы тут ему дали кастомную настройку.
```

## nginx-service.yaml
```
Это обязательный этап, каждому нужно сервис. В нашес случае так как nginx выходит наружу это у нас ClusterIP
```

## nginx-main.yaml
```
Здесь саммый смак поисходит.
#Мини структура отсебя

-------------------------------
apiVersio / kind / metada
-------------------------------
spec = replicas 3
-------------------------------
spec = container, resources, limits
-------------------------------
volume mounts = where to mount
-------------------------------
Liveness and Readiness Probes
-------------------------------
volumes: what to mount
```

#### What to do:
1. Run config
2. Run service
3. Run main

`Note Important` - в самом маин мы указали `namespace` = production. Так как у нас `default` не production, чтобы сделать port-forwar нужно не забыть указать `-n production` чтобы он занл с какого **namespace** брать. 

```sh
kubectl port-forward --address 0.0.0.0 -n production deployment/nginx-pattern-prod
```