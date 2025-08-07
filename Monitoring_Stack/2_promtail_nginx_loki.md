# Настройка Promtail для отправки Nginx access.log в Loki

## Предварительные требования

- Loki уже работает в Docker Compose
- Уже есть Grafana и Prometheus
- Nginx access.log реально пишется на prx-серверах (например, /var/log/nginx/access.log)
- Для каждого сервера с логами **нужно ставить Promtail отдельно**

---

## Шаг 1. Установка Promtail на сервер с логами Nginx

### 1.1. Найти версию Loki (по желанию)

```bash
docker ps    # Узнать имя/ID контейнера Loki
docker exec <CONTAINER_ID> /usr/bin/loki --version
# Например:
docker exec a712a476e406 /usr/bin/loki --version
# loki, version 3.5.1
```

### 1.2. Скачать и установить Promtail

```bash
cd /tmp/
wget https://github.com/grafana/loki/releases/download/v3.5.2/promtail-linux-amd64.zip
apt install unzip -y                   # Если unzip ещё не установлен
unzip promtail-linux-amd64.zip
chmod a+X promtail-linux-amd64
cp promtail-linux-amd64 /usr/local/bin/promtail

# Проверить версию:
promtail --version
```

---

## Шаг 2. Настройка Promtail

### 2.1. Создаём конфиг /etc/promtail.yaml

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/log/promtail-positions.yaml

clients:
  - url: http://10.100.93.5:3100/loki/api/v1/push   # Адрес сервиса Loki

scrape_configs:
  - job_name: nginx-logs
    static_configs:
      - targets:
          - localhost
        labels:
          job: nginx-access        # Этот label будет виден в Grafana
          host: prx01              # Измени на имя своего сервера!
          __path__: /var/log/nginx/access.log
```

> ⚠️ **Важно!**
> 
> - `host: prx01` — указывай имя сервера, чтобы различать логи от разных хостов.
> - `job: nginx-access` — будет использоваться для поиска в Grafana.

---

## Шаг 3. Открытие доступа к Loki (порт 3100)

- Убедись, что порт 3100/TCP на сервере с Loki открыт для prx-серверов (например, через UFW, iptables или security groups).

- Пример (для UFW):
  
  ```bash
  ufw allow from <PRX_IP>/32 to any port 3100 proto tcp
  ```

---

## Шаг 4. Запуск и автозапуск Promtail

### 4.1. Тестовый запуск

```bash
promtail -config.file /etc/promtail.yaml
```

### 4.2. Создание systemd-сервиса /etc/systemd/system/promtail.service

```ini
[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### 4.3. Включаем сервис

```bash
systemctl daemon-reload
systemctl enable --now promtail
systemctl status promtail      # Проверяем статус
journalctl -u promtail -n 50   # Логи Promtail
```

---

## Шаг 5. Добавляем Loki в Grafana

1. Зайди в **Grafana → Data Sources → Add New Data Source**

2. Выбери **Loki**

3. В поле **URL** укажи:
   
   ```
   http://10.100.93.5:3100
   ```

4. **Save & Test**

---

## Шаг 6. Проверяем логи через Grafana

1. Открой **Explore**

2. В источниках данных выбери **Loki**

3. Простой запрос для поиска access.log:
   
   ```
   {job="nginx-access"}
   ```

4. Можно фильтровать по host, искать по коду ответа, URI и т.д.

---

## Примеры фильтров в Explore

- Все ошибки 500:
  
  ```
  {job="nginx-access"} |= " 500 "
  ```

- Логи с конкретного сервера:
  
  ```
  {job="nginx-access", host="prx01"}
  ```
