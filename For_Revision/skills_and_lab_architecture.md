
# Твои навыки

1. **LVM**
   - Команды: `lsblk`, `fdisk`, `pvcreate`, `vgcreate`, `lvcreate`

2. **NFS**
   - Полная настройка сервера и клиента

3. *(зарезервировано)*

4. **Управление пользователями и группами**

5. **Резервное копирование**
   - Утилиты: `dump`, `tar`

6. **Shell-скрипты**
   - Автоматизация задач, создание `.sh` скриптов

7. **Cron**
   - Настройка планировщика заданий

8. **VirtualHost / Apache / Laravel**
   - Файл: `host.conf`
   - Команды: `a2ensite`, `a2dissite`, `php artisan`

9. **.env-файлы**
   - Переменные окружения для приложений Laravel и других

10. **MySQL & PostgreSQL**
   - Установка, создание БД, пользователи, подключение

11. **Nginx / Keepalived**
   - `sites-available/*.conf`
   - `upstream`, `proxy_pass`
   - `keepalived.conf`, `check_nginx.sh`
   - Настройка: `vrrp_script`, `unicast`, `VIP`, `track`

12. **DNS (bind9)**
   - Файлы: `named.conf.local`, файлы зоны, apparmor
   - Ресурсные записи: NS / A / SOA

13. **Iptables** *(создать супер-гайд + больше практики)*
   - Файл: `/etc/iptables/rules.v4`
   - Сохранение: `netfilter-persistent save`

14. **История VirtualHosts Nginx**
   - WAS → `/etc/nginx/sites-available/app.lab.local.conf`
   - NOW:
     - `/etc/nginx/sites-available/laravel.lab.local.conf`
     - `/etc/nginx/sites-available/zabbix.lab.local.conf`

15. **Zabbix**

16. **Netplan?**

17. **SSH по RSA-ключам**

---

# Архитектура проекта (2 июня 2025)

## Общая карта
Команда для отображения активных сервисов:  
`systemctl --type=service --state=running`

Miro-доска: [Ссылка на доску](https://miro.com/app/board/uXjVL5A7FTU=/)

---

## Сервера

### **93.3 – Proxy Master**  
### **93.4 – Proxy Slave**
- HTTPS / TLS / SSL
- Nginx Loadbalancer
- Keepalived: VIP, Proxypass, Unicast, check_nginx.sh, vrrp_script
- zabbix-agent

### **93.5 – App01**  
### **93.6 – App02**
- LVM
- IPTABLES
- NFS Server
- Laravel + PHP + Composer
- MySQL Client
- Виртуальный хост `app02.conf`
- zabbix-agent
- Dockerfile на 93.6

### **93.7 – App03 / Zabbix**
- DNS (bind9)
- NFS
- Виртуальные хосты:
  - `laravel.lab.local` → Proxy → App01/App02/App03
  - `zabbix.lab.local` → Proxy → App03
- zabbix-agent

### **93.8 – DB Server**
- MySQL
- PostgreSQL
- zabbix-agent
