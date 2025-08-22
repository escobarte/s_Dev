# 📘 Установка и миграция BIND9 на LVM (93.8)

## 🔧 Шаг 1: Создание LVM

**Цель:** Выделить отдельный том под конфигурации и данные DNS.

```bash
# Разметка диска
sudo fdisk /dev/sdb
# Внутри fdisk: n, p, 1, Enter, Enter, t, 8e, p, w

# Создание LVM
sudo pvcreate /dev/sdb1
sudo vgcreate DNS /dev/sdb1
sudo lvcreate -n lv -L 3G DNS
sudo mkfs.ext4 /dev/DNS/lv

# Монтирование
sudo mkdir -p /mnt/dns
echo '/dev/DNS/lv /mnt/dns ext4 defaults 2 0' | sudo tee -a /etc/fstab
sudo mount -a
sudo systemctl daemon-reload
```

---

## 📦 Шаг 2: Установка BIND9

```bash
sudo apt install bind9 bind9utils bind9-doc
sudo systemctl stop named

# Перенос конфигурации
sudo rsync -avP /etc/bind/ /mnt/dns/bind/
sudo chown -R bind:bind /mnt/dns/bind
sudo chmod -R 775 /mnt/dns/bind
```

### ⚠ Проблема: `permission denied` от AppArmor

```bash
sudo nano /etc/apparmor.d/usr.sbin.named
# Добавить:
# /mnt/dns/bind/** r,

sudo systemctl reload apparmor
```

---

## ⚙️ Шаг 3: Явный путь к конфигу, отказ от симлинков

```bash
sudo rm -rf /etc/bind
sudo mkdir -p /etc/systemd/system/named.service.d/
sudo nano /etc/systemd/system/named.service.d/override.conf
```

**Содержимое override.conf:**

```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/named -f -c /mnt/dns/bind/named.conf
```

```bash
# В файле named.conf заменить пути:
include "/mnt/dns/bind/named.conf.options";
include "/mnt/dns/bind/named.conf.local";
include "/mnt/dns/bind/named.conf.default-zones";

sudo systemctl daemon-reload
sudo systemctl start named
sudo systemctl enable named
```

### 🧹 Удаление конфликтных `.jnl` файлов

```bash
sudo systemctl stop named.service
sudo pkill -9 named
sudo rm -f /var/cache/bind/managed-service-keys.bind.jnl
```

---

## 🌐 Шаг 4: Настройка зоны `lab.local`

```bash
sudo nano /mnt/dns/bind/named.conf.local
```

**Добавить:**

```conf
zone "lab.local" {
    type master;
    file "/mnt/dns/bind/db.lab.local";
};
```

```bash
sudo cp /mnt/dns/bind/db.local /mnt/dns/bind/db.lab.local
sudo nano /mnt/dns/bind/db.lab.local
```

**Пример содержимого:**

```
$TTL    604800
@       IN      SOA     lab.local. root.lab.local. (
                          2         ; Serial
                     604800         ; Refresh
                      86400         ; Retry
                    2419200         ; Expire
                     604800 )       ; Negative Cache TTL

        IN      NS      lab.local.
app     IN      A       185.108.183.205
```

---

## ✅ Проверки

```bash
sudo named-checkconf /mnt/dns/bind/named.conf
sudo named-checkzone lab.local /mnt/dns/bind/db.lab.local
sudo systemctl restart named
sudo systemctl status named
sudo journalctl -xeu named.service
```

---

## 🧩 Решённые проблемы

| Проблема                       | Решение                                                  |
| ------------------------------ | -------------------------------------------------------- |
| AppArmor блокирует /mnt/dns    | Добавлен путь в профиль `/etc/apparmor.d/usr.sbin.named` |
| Симлинки нестабильны           | Использован `override.conf` с прямым ExecStart           |
| Ошибки с managed-keys.bind.jnl | Удалены `.jnl` файлы, перезапущен `named`                |

---

## 🧭 Дальнейшие шаги

- [x] Настроен основной сервер DNS
- [ ] Перенос `/var/cache/bind` и `/var/lib/bind` (при необходимости)
- [ ] Добавление reverse-зоны (PTR)
- [ ] Тестирование `dig`, `nslookup`, `host` с клиента
- [ ] Настройка slave-сервера для отказоустойчивости
- [ ] Автоматизация с помощью Ansible или bash-скрипта
