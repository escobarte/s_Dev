
# Установка Prometheus Node Exporter и интеграция с Prometheus

---

## 1. Установка Node Exporter

```bash
# Скачиваем последнюю версию Node Exporter
wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.9.1.linux-amd64.tar.gz

# Распаковываем архив
tar xvf node_exporter-1.9.1.linux-amd64.tar.gz

# Копируем бинарник в /usr/local/bin
cd node_exporter-1.9.1.linux-amd64
cp node_exporter /usr/local/bin
cd ..

# Удаляем лишние файлы
rm -rf ./node_exporter-1.9.1.linux-amd64
rm -rf ./node_exporter-1.9.1.linux-amd64.tar.gz

# Создаём системного пользователя
sudo useradd --no-create-home --shell /bin/false node_exporter

# Даем права на бинарник пользователю node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

---

## 2. Создание systemd unit для Node Exporter

Файл: `/etc/systemd/system/node_exporter.service`
```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address="0.0.0.0:9100"
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Активируем сервис:
```bash
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter
```

---

## 3. IPTABLES (открываем порт для Prometheus сервера)

```bash
iptables -A INPUT -p tcp -s 10.100.93.5 --dport 9100 -j ACCEPT
```

---

## 4. Добавление Node Exporter в Prometheus

Открыть `/mnt/prometheus_data/prometheus.yml` на Prometheus сервере и добавить/обновить:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets:
          - '10.100.93.3:9100'
          - '10.100.93.4:9100'
```

---

## 5. Перезапуск Prometheus (docker-compose)

```bash
docker compose restart prometheus
docker ps
```

---

## 6. Проверка статуса targets в Prometheus

- Открой в браузере:
  ```
  http://10.100.93.5:9090/targets
  ```
- Убедись, что все нужные endpoints находятся в состоянии UP

