# Kibana Installation on 10.100.93.5

---

## 1. Скачивание и установка Kibana

```bash
# Скачиваем deb-пакет Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-9.0.3-amd64.deb

# Проверяем контрольную сумму (опционально)
shasum -a 512 kibana-9.0.3-amd64.deb

# Устанавливаем пакет
sudo dpkg -i kibana-9.0.3-amd64.deb
```

---

## 2. Настройка Kibana (`/etc/kibana/kibana.yml`)

Открыть файл конфигурации и добавить/проверить:

```yaml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://10.100.93.6:9200"]
elasticsearch.username: "kibana_system"
elasticsearch.password: "qwerty12345"
pid.file: /run/kibana/kibana.pid
```

---

## 3. Запуск и проверка статуса Kibana

```bash
systemctl enable kibana
systemctl start kibana
systemctl status kibana
journalctl -u kibana -f    # Смотреть логи работы Kibana
```

---

## 4. Проверка соединения с Elasticsearch

На сервере Elasticsearch выполнить:

```bash
curl -v -u elastic:*b7u1ak*HqfpIklumVfb http://10.100.93.6:9200/
```

---

## 5. Решение проблемы с авторизацией Kibana (логин/пароль)

### Проблема

> При попытке соединить Kibana с Elasticsearch через Token — не удалось.
> Решение: Использовать стандартные логин/пароль.

### Шаги для исправления:

#### A) На сервере Elasticsearch установить пароль для пользователя `kibana_system`:

```bash
curl -XPOST -u elastic:*b7u1ak*HqfpIklumVfb "http://10.100.93.6:9200/_security/user/kibana_system/_password" -H "Content-Type: application/json" -d'
{
  "password" : "qwerty12345"
}
'
```

#### B) Указать логин и пароль в `kibana.yml`:

```yaml
elasticsearch.username: "kibana_system"
elasticsearch.password: "qwerty12345"
```

---

## 6. Авторизация в Kibana

- Для авторизации через веб-интерфейс используются пользователи **Elasticsearch** (а не token).
- По умолчанию:
  - **Username:** `elastic`
  - **Password:** `*b7u1ak*HqfpIklumVfb`
