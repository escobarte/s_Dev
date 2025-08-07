## 🔥 IPTables Команды: сохранение, очистка, настройка доступа и NAT

---

### 📂 Поиск и сохранение текущих правил

```bash
find / -name iptables
find / -name iptables-save

cat /usr/sbin/iptables-save
sudo /usr/sbin/iptables-save > /tmp/iptables-save-default.conf
chmod +x /tmp/iptables-save-default.conf
nano /tmp/iptables-save-default.conf
```

---

### 📦 Установка пакетов

```bash
apt install iptables iptables-persistent
```

---

### 📋 Просмотр правил

```bash
iptables -L -n -v
iptables -L INPUT --line-numbers
iptables -L FORWARD -n -v
iptables -L DOCKER-USER -n -v
iptables -t nat -L POSTROUTING -n -v
```

---

### 🧹 Очистка и базовая настройка

```bash
sudo iptables -F  # flush all

# Разрешить loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Разрешить установленные соединения
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# SSH доступ с подсети
sudo iptables -A INPUT -p tcp --dport 22 -s 172.29.31.0/24 -j ACCEPT

# HTTP/HTTPS
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# ICMP ping
sudo iptables -I INPUT -p icmp --icmp-type echo-request -s 172.29.31.0/24 -j ACCEPT

# Политики
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
```

---

### 🔁 Управление правилами по номеру

```bash
iptables -L INPUT --line-numbers
iptables -D INPUT 2        # удалить правило
iptables -I INPUT 4 ...    # вставить на позицию 4
```

---

### 🧪 Примеры разрешений

```bash
iptables -I INPUT -p tcp -s 10.100.93.7 --dport 10050 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 8080,7080 -j ACCEPT
iptables -I INPUT 4 -p udp -s 172.29.31.16/28 --dport 53 -j ACCEPT
iptables -I INPUT 5 -p tcp -s 172.29.31.16/28 --dport 53 -j ACCEPT
```

---

### 🐳 Настройка правил для Docker

```bash
iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o docker0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE

# Сетевые связи с внешкой через DOCKER-USER
iptables -I DOCKER-USER -i docker0 -o ens192 -j ACCEPT
iptables -I DOCKER-USER -i ens192 -o docker0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

---

### 🔎 Фильтрация по портам

```bash
sudo iptables -L INPUT -v -n | grep -E '7080|8080'
sudo iptables -L INPUT -v -n | grep -E '70|80'
```

---

### 🧱 Другие удобные флаги

```bash
sudo iptables -L -n -v --line-numbers
```
