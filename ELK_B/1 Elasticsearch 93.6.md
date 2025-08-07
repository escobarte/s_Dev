# Elasticsearch Installation on 10.100.93.6

## Основные этапы

1. Подготовка LVM  
2. Установка Elasticsearch  
   2.1. Привилегии пользователя  
3. IPTABLES (не требуется)

---

## 1. Подготовка LVM для Elasticsearch

```bash
# Создать раздел на /dev/sdb, размер ~15ГБ, тип 8e (LVM)
fdisk /dev/sdb
# команды внутри fdisk: n, p, +15G, t, 8e, w

# Создать Physical Volume
pvcreate /dev/sdb5

# Создать Volume Group
vgcreate elastic /dev/sdb5

# Создать Logical Volume
lvcreate -n search -L 14.9G elastic

# Форматировать раздел
mkfs.ext4 /dev/mapper/elastic-search

# Создать директорию и смонтировать
sudo mkdir -p /var/lib/elasticsearch

# Добавить в /etc/fstab для автоматического монтирования:
echo '/dev/elastic/search /var/lib/elasticsearch ext4 defaults 2 0' | sudo tee -a /etc/fstab

# Применить монтирование
mount -a

# Обновить systemd и проверить
systemctl daemon-reload
lsblk -f
```

---

## 2. Установка Elasticsearch

```bash
# Добавить GPG-ключ Elastic
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Установить apt-transport-https (если нужно)
sudo apt-get install apt-transport-https

# Добавить репозиторий Elastic 9.x
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-9.x.list

# Установить Elasticsearch
sudo apt update
sudo apt install elasticsearch
```

### 2.1 Настроить пользователя и права

```bash
sudo chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
```

### 2.2 Настройка elasticsearch.yml

Открыть `/etc/elasticsearch/elasticsearch.yml` и добавить/проверить параметры (в конец файла):

```yaml
cluster.name: nginx-elk
node.name: elk-node-1
network.host: 0.0.0.0
http.port: 9200
```

---

## 2.3 Запуск и автозапуск Elasticsearch

```bash
systemctl enable elasticsearch
systemctl start elasticsearch
systemctl status elasticsearch
```

---

## 2.4 Сбросить/создать пароль пользователя elastic

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
# Пример пароля: *b7u1ak*HqfpIklumVfb
```

---

## 2.5 Проверка работы кластера

```bash
curl -u elastic:'*b7u1ak*HqfpIklumVfb' http://localhost:9200/
curl -u elastic:'*b7u1ak*HqfpIklumVfb' http://localhost:9200/_cluster/health?pretty
```

---

## 3. IPTABLES (не требуется)

**Входящий доступ к 9200 открыт по умолчанию для этого сервера**

---

## 4. Примеры запросов

**Показать индексы, связанные с nginx-access:**

```bash
curl -u elastic:'*b7u1ak*HqfpIklumVfb' http://10.100.93.6:9200/_cat/indices?v | grep nginx-access
```

**Данные для входа:**

- login: `elastic`
- password: `*b7u1ak*HqfpIklumVfb`
