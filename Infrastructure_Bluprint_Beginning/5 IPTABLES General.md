# Работа с iptables в Ubuntu

## Основные пути и команды

```bash
# Основной конфигурационный файл iptables
/etc/iptables/rules.v4

# Сервис iptables в systemd
/usr/lib/systemd/system/iptables.service

# Просмотр текущих правил в читаемом формате
iptables -L -n -v

# Просмотр правил в виде команд
iptables -S
```

---

## Поиск файлов в системе

```bash
# Показывает путь к исполняемому файлу iptables-save
which iptables-save

# Находит все возможные пути и бинарники iptables-save
whereis iptables-save

# Ищет файл iptables-save по всей файловой системе
find / -name iptables-save
```

---

## Создание резервной копии правил iptables

```bash
# Сохраняем текущие правила в файл (обязательно указывать версию вручную)
iptables-save > ~/iptables_rules_before_changes.conf

# Делаем файл исполняемым (опционально)
chmod +x ~/iptables_rules_before_changes.conf

# Восстановление правил из резервной копии
iptables-restore < ~/iptables_rules_before_changes.conf
```

---

## Управление отдельными правилами

```bash
# Показывает список правил в INPUT с номерами строк
sudo iptables -L INPUT --line-numbers

# Удаляет правило под номером 5 из INPUT
sudo iptables -D INPUT 5

# Вставляет правило на 5-ю строку, разрешающее ICMP (ping) из указанной подсети
iptables -I INPUT 5 -p icmp --icmp-type echo-request -s 172.29.31.0/24 -j ACCEPT
```

---

## Настройка iptables с нуля

```bash
# Устанавливаем iptables и утилиту для сохранения настроек
sudo apt install iptables iptables-persistent

# Просмотр всех текущих правил в читаемом формате
sudo iptables -L -n -v

# Показывает список правил в INPUT с номерами строк
sudo iptables -L INPUT --line-numbers

# Удаляет все текущие правила
sudo iptables -F

# Разрешает локальный трафик
sudo iptables -A INPUT -i lo -j ACCEPT

# Разрешает пакеты, относящиеся к уже установленным соединениям
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Разрешает подключение по SSH с определённой подсети
sudo iptables -A INPUT -p tcp --dport 22 -s 172.29.31.16/28 -j ACCEPT

# Разрешает HTTP и HTTPS
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Разрешает ICMP (ping) из определённой подсети
sudo iptables -I INPUT -p icmp --icmp-type echo-request -s 172.29.31.16/28 -j ACCEPT

# Устанавливает политику по умолчанию — запрет для входящих соединений
sudo iptables -P INPUT DROP

# Устанавливает политику по умолчанию — запрет на форвардинг пакетов
sudo iptables -P FORWARD DROP

# Устанавливает политику по умолчанию — разрешение на исходящие соединения
sudo iptables -P OUTPUT ACCEPT
```

---

## Сохранение правил после перезагрузки

```bash
# Устанавливаем сервис для автозагрузки iptables
sudo apt install netfilter-persistent

# Сохраняем текущие правила
sudo netfilter-persistent save

# Проверка, где находится iptables-save
find / -name iptables-save  # → /usr/sbin/iptables-save
```

---

## Проверка доступности портов

```bash
# Устанавливаем утилиту nmap
sudo apt install nmap

# Сканируем хост (например, для проверки доступности NGINX)
nmap 10.100.93.4

# Проверяем, разрешён ли доступ на порты 80 и 443 в правилах iptables
sudo iptables -L INPUT -v -n | grep -E '80|443'

# Смотрим, какие порты слушает NGINX
sudo ss -tuln | grep -E '80|443'
sudo netstat -tuln | grep -E '80|443'
```
