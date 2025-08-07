
# Экспорт NGINX метрик с nginx-prometheus-exporter (сервер 93.4 PRX slave)

> ⚠️ Все действия описаны для сервера 93.4 (PRX slave)

---

## 1. Настройка stub_status в NGINX

Файл: `/etc/nginx/conf.d/nginx_status_slave.conf`
```nginx
server {
    listen 81;
    server_name nginx_status_slave;

    location /nginx_status_slave {
        stub_status;
        allow 127.0.0.1;
        allow 10.100.93.5; # Разрешаем Prometheus опрашивать
        deny all;
    }
}
```
Проверить конфиг и перезапустить Nginx:
```bash
nginx -t
systemctl restart nginx
```

Проверить доступность stub_status:
```bash
curl http://127.0.0.1:81/nginx_status_slave
```

---

## 2. Установка nginx-prometheus-exporter

```bash
wget https://github.com/nginx/nginx-prometheus-exporter/releases/download/v1.4.2/nginx-prometheus-exporter_1.4.2_linux_amd64.tar.gz
tar -xzvf nginx-prometheus-exporter_1.4.2_linux_amd64.tar.gz
mv nginx-prometheus-exporter /usr/local/bin/
sudo useradd --system --no-create-home --shell /bin/false nginx-exporter
```

---

## 3. Systemd unit для nginx-prometheus-exporter

Файл: `/etc/systemd/system/nginx-exporter.service`
```ini
[Unit]
Description=nginx-prometheus-exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/nginx-prometheus-exporter -nginx.scrape-uri http://127.0.0.1:81/nginx_status_slave
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Активируем сервис:
```bash
systemctl daemon-reload
systemctl enable nginx-exporter.service
systemctl start nginx-exporter.service
systemctl status nginx-exporter.service
```

---

## 4. IPTABLES (открыть порт для Prometheus сервера)

```bash
iptables -A INPUT -p tcp -s 10.100.93.5 --dport 9113 -j ACCEPT
```

---

## 5. Проверка работы экспортера

```bash
curl http://127.0.0.1:9113/metrics
curl http://10.100.93.4:9113/metrics
```

---

## 6. Добавление job в Prometheus

Открыть `/mnt/prometheus_data/prometheus.yml` на Prometheus сервере и добавить:
```yaml
  - job_name: 'nginx_exporter'
    static_configs:
      - targets:
          - '10.100.93.3:9113'
          - '10.100.93.4:9113'
```

---

## 7. Проверка из Prometheus

Проверить доступность метрик с Prometheus сервера:
```bash
curl -v http://10.100.93.4:9113/metrics | grep cpu
```

---

## 8. Перезапуск Prometheus (docker-compose)

```bash
cd /opt/monitoring-stack
docker compose restart prometheus
watch -n2 docker ps
```
