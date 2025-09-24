# Настройка локального DNS через dnsmasq и iptables

## Подготовка и установка

```bash
# Открываем конфигурацию systemd-resolved (возможно, уже редактировали)
sudo nano /etc/systemd/resolved.conf
```

---

## Шаг 1: Установка и остановка dnsmasq

```bash
# Устанавливаем dnsmasq
apt install dnsmasq

# Останавливаем службу, чтобы настроить
systemctl stop dnsmasq
```

---

## Правила iptables для доступа к DNS (порт 53)

```bash
# Просмотр правил INPUT с номерами строк
iptables -L INPUT --line-numbers

# Разрешаем DNS-запросы по UDP от клиента (172.29.31.24)
sudo iptables -I INPUT 4 -p udp -s 172.29.31.24 --dport 53 -j ACCEPT

# Разрешаем DNS-запросы по TCP от клиента (172.29.31.24)
sudo iptables -I INPUT 5 -p tcp -s 172.29.31.24 --dport 53 -j ACCEPT

# Проверка активных правил
sudo iptables -L -n -v

# Сохраняем изменения в правилах iptables
sudo netfilter-persistent save
```

---

## Конфигурация dnsmasq

```bash
# Создаём отдельный конфигурационный файл
sudo nano /etc/dnsmasq.d/local_dns.conf
```

Пример содержимого файла `local_dns.conf`:

```
listen-address=127.0.0.1,10.100.93.3
server=8.8.8.8
server=8.8.4.4
cache-size=1000

# Привязка доменных имён к локальным IP
address=/nginxproxy1.local/10.100.93.3
address=/nginxproxy2.local/10.100.93.4
address=/app.lab.local/10.100.93.2  # VIP
```

> Внимание: в оригинале была опечатка `adderss` — должна быть `address`

---

## Запуск и проверка dnsmasq

```bash
# Запускаем службу
sudo systemctl start dnsmasq

# Включаем автозагрузку
sudo systemctl enable dnsmasq

# Проверяем статус
sudo systemctl status dnsmasq
```

---

## Устранение ошибок (Troubleshooting)

**Примеры ошибок:**
```
bad option at line 7 of /etc/dnsmasq.d/local_dns.conf
failed to create listening socket for port 53: Address already in use
```

### Шаги для устранения

```bash
# Проверяем, какой процесс занимает порт 53
sudo ss -upan 'sport = :domain' || sudo lsof -i UDP:53
sudo ss -utan 'sport = :domain' || sudo lsof -i TCP:53

# Проверяем PID и процесс
ls -l /proc/720
```

**Решение: отключить DNSStubListener**

```bash
# Открываем конфигурацию
sudo nano /etc/systemd/resolved.conf

# Устанавливаем параметр
DNSStubListener=no

# Перезапускаем службу
systemctl restart systemd-resolved
```

---

## КЛИЕНТСКИЙ ПК: Проверка DNS

```bash
# Указываем DNS-сервер
# → 10.100.93.3

# Сброс кеша DNS
ipconfig /flushdns

# Проверка разрешения имени
nslookup nginxproxy1.local
```

---

## Удаление dnsmasq

```bash
# Останавливаем службу
systemctl stop dnsmasq

# Отключаем автозагрузку
systemctl disable dnsmasq

# Удаляем пакет
apt remove dnsmasq

# Поиск всех следов dnsmasq
find / -name dnsmasq
rm -f *all paths that were found*

# Альтернативный способ найти всё
sudo find / -type f -iname "*dnsmasq*" 2>/dev/null
```
