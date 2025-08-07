
# Архитектура проекта

```
              🌍 Public IP: 185.108.183.205
                         │
                         ▼
                  VIP: 10.100.93.2 (Keepalived)
                   │               │
        ┌──────────┘               └──────────┐
        ▼                                     ▼
    Prx01 (93.3)   <--unicast-->          Prx02 (93.4)
        │                                     │
        └──────→ балансировка на Laravel ↓────┘
                   ┌─────┬─────┬─────┐
                   ▼     ▼     ▼
                App01  App02  App03 (Zabbix)
                            │
                            ▼
                         DB01 (93.8)
                 → MySQL (Laravel) + PostgreSQL (Zabbix) + DNS
```

---

## Серверы

| Название | IP | Роль |
|----------|----|------|
| 🌐 Public IP | 185.108.183.205 | Доступ извне |
| Prx01 | 10.100.93.3 | NGINX + Keepalived (VIP) |
| Prx02 | 10.100.93.4 | NGINX + Keepalived (VIP) |
| App01 | 10.100.93.5 | Laravel |
| App02 | 10.100.93.6 | Laravel |
| App03 | 10.100.93.7 | Laravel + Zabbix |
| DB01 | 10.100.93.8 | MySQL + PostgreSQL + DNS |

DNS (app.lab.local) обслуживается через DB01.

---

## Компоненты

- **LVM**
- **PHP and modules**
- **Laravel + Composer + Artisan**
- **Apache2 + a2dissite/a2ensite**
- **MySQL**
- **NGINX (Upstream = Loadbalancer)**
- **Keepalived (Unicast)**
- **Bind9 / named / AppArmor**
- **HTTPS (Self-Signed SSL)**
- **IPTABLES**
- **Zabbix**
- **PostgreSQL**

---

## ✅ Возможна ли кластеризация?

| Компонент             | Кластеризация | Комментарий |
|-----------------------|---------------|-------------|
| MySQL (Laravel)       | ✅ Да          | MySQL Replication или Galera Cluster |
| PostgreSQL (Zabbix)   | ✅ Да          | Streaming Replication + Patroni |
| Zabbix                | ⚠ Частично     | Может читать с кластера PostgreSQL |
| DNS (BIND)            | ⚠ Ручной failover | Master/Slave возможен, редко нужен |
| Laravel backend       | ✅ Уже кластер | App01–03 с балансировкой через LB |

---

## 🧱 Пример гибридной архитектуры (реалистичный вариант)

```
╔══════════════════╗
║     KUBERNETES   ║
║ - Laravel Apps   ║
║ - Zabbix Server  ║
║ - Prometheus     ║
║ - Grafana        ║
╚══════════════════╝
        │
        ▼
╔════════════════════╗
║     Прокси (VIP)   ║
║  Prx01/Prx02 NGINX ║
╚════════════════════╝
        │
        ▼
╔════════════════════╗
║     DB01 (bare OS) ║
║ - MySQL            ║
║ - PostgreSQL       ║
║ - DNS              ║
╚════════════════════╝
```
