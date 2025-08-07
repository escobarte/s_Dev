
# Logstash Installation on 10.100.93.7

---

## 0. Подготовка LVM

> **Используется тот же принцип, что и в инструкции по Elasticsearch**  
> (см. раздел LVM в предыдущем markdown-файле)

---

## 1. Установка Logstash

```bash
# Добавить ключ и репозиторий Elastic
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg

echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update
sudo apt install logstash

# Запустить и включить сервис
systemctl enable logstash
systemctl start logstash
systemctl status logstash
```

---

## 2. Настройка Logstash (использование grok)

> ⚠️❗📝 **Внимание:**  
> В `/etc/logstash/conf.d/` **не должно быть более одного `.conf` файла** — оставь только нужный файл!

### Пример конфигурации: `/etc/logstash/conf.d/accee-log.conf`

```conf
input {
    beats {
        port => "5044"
    }
}
filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    geoip {
        source => "clientip"
    }
}
output {
    elasticsearch {
        hosts => ["http://10.100.93.6:9200"]
        user => "elastic"
        password => "*b7u1ak*HqfpIklumVfb"
        index => "access-log-%{+YYYY.MM.dd}"
        manage_template => false
    }
}
```

---

## 3. Проверка индексов в Elasticsearch

```bash
curl -u elastic:*b7u1ak*HqfpIklumVfb http://10.100.93.6:9200/_cat/indices?v
```

---

## 4. Перезапуск сервисов Logstash и Filebeat

```bash
sudo systemctl restart logstash
sudo systemctl restart filebeat
```

