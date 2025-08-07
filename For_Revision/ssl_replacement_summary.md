
# Замена SSL-сертификата на сервере
_Author: Alexandr Dagutan_  
_Date: Jun 20, 2025_

---

## 🛠 Общий процесс

Произведена замена SSL-сертификата `wild.gov.md.*` на множестве доменов на сервере с IP `10.100.45.7`. Сценарий разбит на две части:
1. **Действия с WSL (локально)**
2. **Действия на сервере (удалённо по SSH)**

---

## 📄 Часть 1: Команды WSL (локальная машина)

```bash
ssh 10.100.45.7  # Подключение к серверу
scp ssl/gov.md-2025/wild.gov.md.* 10.100.45.7:~/  # Передача нового SSL-сертификата и ключа на сервер
cat > list.txt  # Создание списка доменов для проверки
vim list.txt  # Редактирование списка
cat list.txt  # Просмотр содержимого списка
for DOMAIN in $(cat list.txt); do host $DOMAIN; done  # Проверка DNS разрешения доменов
for DOMAIN in $(cat list.txt); do host $DOMAIN; done | grep 188  # Фильтрация доменов, указывающих на IP (например 188.*)
openssl s_client -connect gestionare-sanctiuni.gov.md:443 -dates -noout  # Проверка дат действия текущего сертификата
openssl s_client -connect gestionare-sanctiuni.gov.md:443 | openssl x509 -text -noout | grep NotBefore  # Просмотр начала срока действия
curl https://gestionare-sanctiuni.gov.md -vI --stderr - | grep "expire date"  # Проверка даты истечения через curl
for DOMAIN in $(cat list.txt); do curl https://$DOMAIN -vI --stderr - | grep "expire date"; done  # Массовая проверка доменов
```

📌 **Что важно**:
- Была произведена массовая диагностика сроков действия сертификатов для gov.md-доменов.
- Использованы `openssl` и `curl` для валидации и инспекции SSL-состояния.
- Передача новых сертификатов выполнена через `scp`.

---

## 📁 Часть 2: Команды на сервере

```bash
grep ssl_cert /etc/nginx/conf.d/*conf  # Поиск строк с ssl-сертификатами в nginx-конфигурации
cp wild.gov.md.* /etc/nginx/ssl/  # Копирование новых сертификатов в нужную директорию
cd /etc/nginx/conf.d/ && ls  # Переход и просмотр конфигурационных файлов
vim *.conf  # Редактирование вручную
nginx -t && systemctl reload nginx  # Проверка конфигурации и перезагрузка nginx

# Массовая замена имён сертификатов
sed 's/wgov.pem/wild.gov.md.pem/g' -i *conf  # Заменяем старые имена сертификатов
sed 's/wgov.key/wild.gov.md.key/g' -i *conf  # Заменяем приватные ключи
sed 's/private24.key/wild.gov.md.key/g' -i *conf  # Ещё одна замена ключей
sed 's/wild.gov.md24.pem/wild.gov.md.pem/g' -i *conf  # Уточнение с суффиксом

grep -l wild.gov.md.pem *conf  # Проверка, где уже применён новый сертификат
nginx -t && systemctl reload nginx  # Повторная проверка и перезагрузка

# Логирование и тесты
tail -f /var/log/nginx/*.log  # Мониторинг логов доступа
grep server_name *conf | awk '{print $3}' | grep gov.md | uniq  # Получение списка уникальных доменов gov.md
curl ifconfig.co  # Проверка внешнего IP сервера

cat /etc/keepalived/keepalived.conf  # Проверка настройки Keepalived (возможно кластер)
```

📌 **Ключевые замечания**:
- Проведена **массовая замена SSL-ссылок** в `.conf` файлах (`sed`).
- Подтверждено через `nginx -t`, что конфигурация валидна.
- Использовалась **фильтрация по имени серверов** для системной замены.
- Применяется `Keepalived`, возможно сервер работает в HA-кластере.

---

## 💡 Рекомендации

- Убедиться, что все конфигурации действительно перезагрузились (`systemctl status nginx`).
- В будущем можно автоматизировать замену сертификатов скриптом с валидацией (CI/CD).
- Логи `modsec`, `nginx error`, и `access` желательно архивировать для отката при сбоях.

---

Готово.
