# Prometheus + Grafana + Loki через Docker Compose

## 1. Создание LVM и папок

### Пример разметки диска

```bash
# Пример выходных данных fdisk/lsblk:
# /dev/sdb3       ...  42G  Extended
# /dev/sdb5       ...  2.8G Linux LVM  (Prometheus)
# /dev/sdb6       ...  2.8G Linux LVM  (Grafana)
# /dev/sdb7       ...  6.5G Linux LVM  (Loki)
```

### Создание LVM и монтирование

```bash
# 1. Инициализация Physical Volume
pvcreate /dev/sdb5

# 2. Создание Volume Group
vgcreate vg_prom /dev/sdb5

# 3. Создание Logical Volume
lvcreate -n prometheus -L 2.75G vg_prom

# 4. Форматирование раздела
mkfs.ext4 /dev/mapper/vg_prom-prometheus

# 5. Создание каталога и монтирование
mkdir -p /mnt/prometheus_data
mount /dev/mapper/vg_prom-prometheus /mnt/prometheus_data/

# 6. Добавление в автозагрузку
echo '/dev/vg_prom/prometheus /mnt/prometheus_data ext4 defaults 2 0' | sudo tee -a /etc/fstab
```

> Аналогично создать и смонтировать тома для Grafana и Loki, примеры папок:
> 
> - `/mnt/grafana_data` = 3GB  
> - `/mnt/loki_data` = 6GB  
> - `/mnt/loki_data/wal`  

---

## 2. Права на папки

```bash
# Grafana (ID 472)
chown -R 472:472 /mnt/grafana_data
chmod -R 755 /mnt/grafana_data

# Loki (ID 10001)
chown -R 10001:10001 /mnt/loki_data
chmod -R 755 /mnt/loki_data

mkdir -p /mnt/loki_data/wal
chown -R 10001:10001 /mnt/loki_data/wal
chmod -R 755 /mnt/loki_data/wal
```

> **Примечание:**  
> ID пользователей/групп можно узнать из документации контейнеров.

---

## 3. Подготовка конфигов

### Prometheus

Файл: `/mnt/prometheus_data/prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### Loki

Файл: `/mnt/loki_data/local-config.yaml`

```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1

storage_config:
  boltdb:
    directory: /etc/loki/index

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

limits_config:
  allow_structured_metadata: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
```

---

## 4. Docker Compose

Файл: `/opt/monitoring-stack/docker-compose.yaml`

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - /mnt/prometheus_data:/etc/prometheus
    ports:
      - "9090:9090"
    restart: always

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - /mnt/grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    restart: always

  loki:
    image: grafana/loki:latest
    container_name: loki
    volumes:
      - /mnt/loki_data:/etc/loki
      - /mnt/loki_data/wal:/wal
    command: -config.file=/etc/loki/local-config.yaml
    ports:
      - "3100:3100"
    restart: always
```

> **Внимание:**  
> Файл должен находиться в каталоге `/opt/monitoring-stack`.

---

## 5. Развертывание и проверка

```bash
cd /opt/monitoring-stack
docker compose up -d        # Запуск всех сервисов в фоне
docker ps                   # Проверка состояния контейнеров
```

**Проверка в браузере:**

- Prometheus:   `http://10.100.93.5:9090`
- Grafana:      `http://10.100.93.5:3000`
- Loki API:     `http://10.100.93.5:3100`
