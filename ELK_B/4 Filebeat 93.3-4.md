
# Filebeat Installation on 10.100.93.3-4

---

## 1. Установка Filebeat

```bash
# Добавить ключ репозитория Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Установить apt-transport-https (если ещё не установлен)
sudo apt-get install apt-transport-https

# Добавить репозиторий Elastic 8.x
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Обновить индексы и установить Filebeat
sudo apt update
sudo apt install filebeat -y
```

---

## 2. Конфигурация Filebeat

Открыть файл `/etc/filebeat/filebeat.yml` и настроить так:

```yaml
# ============================== Filebeat inputs ===============================
filebeat.inputs:
  - type: filestream
    id: my-filestream-id          # Уникальный ID для input
    enabled: true
    paths:
      - /var/log/nginx/*.log      # Путь к логам nginx

# ------------------------------ Logstash Output -------------------------------
output.logstash:
  hosts: ["10.100.93.7:5044"]     # Адрес Logstash сервера
```

---

## 3. Проверка конфигурации

```bash
filebeat test config        # Проверка синтаксиса конфигурации
filebeat test output       # Проверка подключения к Logstash
```

---

## 4. Перезапуск сервисов

```bash
sudo systemctl restart logstash
sudo systemctl restart filebeat
```

