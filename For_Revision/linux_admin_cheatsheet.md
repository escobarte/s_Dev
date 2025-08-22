## Linux Admin Cheatsheet

### 🔁 Общие ключи команд

```bash
-r  # Recursive — рекурсивно (не только в указанной директории, но и во всех поддиректориях и файлах)
-f  # Follow — сразу выводить новые строки, как только они появляются в файле (используется в tail)
```

---

### 📜 История команд (фильтрация)

```bash
# Убираем номера и время из вывода history
history | awk '{$1=$2=$3="" ; print $0}' | sed 's/^ *//'
```

---

### 🔍 Поиск и перемещение файлов

```bash
# Найти файлы с именем, содержащим "Gemeni" и переместить их
find /path/to/source/folder/ -maxdepth 1 -type f -name "*Gemeni*" -exec mv {} /path/to/destination/folder/ \;
```

---

### 🔎 Поиск по содержимому файлов

```bash
grep -r "unicast" /etc/                     # Ищет "unicast" во всех файлах внутри /etc
grep -r ssl_cert *conf                      # Ищет "ssl_cert" во всех файлах с расширением *conf
```

---

### 📄 Просмотр логов

```bash
tail -f /var/log/nginx                      # Показывает последние 10 строк + новые строки сразу

# Показывает последние 50 строк
tail -n 50 /var/log/zabbix/zabbix_server.log

# Какие апдейты были установленны
cat /var/log/apt/history.log
```

---

### 🌐 Сетевые соединения

```bash
ss -tuln | grep 5432                        # Проверить, слушает ли порт 5432
netstat                                     # Показать сетевые соединения (требует apt install net-tools)
netstat -tulnp | grep nginx                 # Инфо по nginx через netstat
ss -tulnp | grep 80 | grep nginx            # Проверить, слушает ли nginx на порту 80
ip a                                        # Показать IP адреса
ip a | grep 93.2                            # Найти конкретный IP

telnet 10.100.93.4 22                       # Проверить доступность порта 22 на IP

tcpdump -ni ens192                          # Слушать трафик на интерфейсе ens192 без DNS/портов
```

---

### 💽 Работа с дисками

```bash
parted /dev/sda print free                  # Показать свободное место на sda
parted /dev/sdb1 unit GB print free         # То же, но в ГБ
du -sh /var/log/* | sort -hr                # Сколько весят файлы в вар лог

df -T                                       # Показать свободное место по файловым системам

apt install sysstat                         # Установка пакета со статистикой

iostat                                      # I/O статистика
vmstat                                      # Статистика памяти
```

---

### 📂 Открытые файлы и процессы

```bash
lsof +f -- /mnt/dns                         # Показать кто использует /mnt/dns
fuser -vm /mnt/dns                          # То же самое
ls -lht                                       # новые файлы по дате изменения
ls -lhu                                       # новые файлы по дате доступа
ls -lhc   # новые файлы по изменению метаданных



ps l                                        # Процессы в длинном формате
ps aux                                      # Все процессы
ps aux | grep nginx                         # Поиск процессов nginx
kill -9 <PID>                               # Принудительное завершение процесса
```

---

### 🛠️ Сервисы systemd

```bash
systemctl --type=service --state=running    # Показать все активные сервисы

journalctl                  # Показать все логи
journalctl -u nginx         # Логи конкретного сервиса
journalctl --since today    # Логи за сегодня
journalctl -b               # Логи текущей загрузки
```

---

### 👥 Управление пользователями и группами

```bash
/etc/shadow        # Хранит хэши паролей пользователей
/etc/passwd        # Инфо о пользователях (uid, shell и тд)
/etc/group         # Информация о группах
id zabbix          # Инфо о пользователе zabbix
```