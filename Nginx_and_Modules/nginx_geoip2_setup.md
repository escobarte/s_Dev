# Установка и настройка модуля geoip2 для NGINX 1.24.0

---

## Шаг 1. Установить зависимости для сборки geoip2 модуля

```bash
sudo apt update
sudo apt install git gcc make libmaxminddb0 libmaxminddb-dev mmdb-bin build-essential
```

---

## Шаг 2. Скачать исходники NGINX нужной версии (1.24.0)

```bash
cd /usr/local/src
sudo wget http://nginx.org/download/nginx-1.24.0.tar.gz
sudo tar -xzvf nginx-1.24.0.tar.gz
cd nginx-1.24.0
```

*В директории `/usr/local/src/nginx-1.24.0` должны появиться исходники nginx.*

---

## Шаг 3. Скачать модуль ngx_http_geoip2_module

```bash
sudo git clone https://github.com/leev/ngx_http_geoip2_module.git
ls -l ngx_http_geoip2_module
```

---

## Шаг 4. Собрать dynamic module geoip2

```bash
sudo apt install libpcre3 libpcre3-dev
sudo apt install zlib1g zlib1g-dev
sudo ./configure --with-compat --add-dynamic-module=./ngx_http_geoip2_module
sudo make modules
ls -lh objs/ngx_http_geoip2_module.so
```

### 4.1 Скопировать модуль в папку модулей nginx

```bash
sudo cp objs/ngx_http_geoip2_module.so /usr/lib/nginx/modules/
```

---

## Шаг 5. Подключить модуль в NGINX

Открыть `/etc/nginx/nginx.conf` и в самом верху добавить:

```nginx
load_module modules/ngx_http_geoip2_module.so;
```

---

## Шаг 6. Получить токен и скачать базы GeoIP2 с MaxMind

1. Зарегистрируйся или зайди в свой аккаунт MaxMind: https://www.maxmind.com
2. Перейди: **My Account → Manage License Keys → Generate New License Key**
3. Сохрани ключ для скачивания баз

---

## Шаг 7. Создай конфиг для geoipupdate

```bash
sudo nano /etc/GeoIP.conf
```

Пример конфига:

```
AccountID YOUR_ACCOUNT_ID
LicenseKey YOUR_LICENSE_KEY
EditionIDs GeoLite2-Country GeoLite2-City
```

---

## Шаг 8. Скачать базы GeoIP2

```bash
sudo apt install geoipupdate
sudo geoipupdate
ls -lh /var/lib/GeoIP/
# Для дебага использовать: geoipupdate -v
```

---

## Шаг 9. Настроить NGINX для работы с GeoIP2

Открыть `/etc/nginx/nginx.conf` и добавить в блок `http { ... }`:

```nginx
http {
    charset utf-8;
    geoip2 /var/lib/GeoIP/GeoLite2-Country.mmdb {
        $geoip2_data_country_code country iso_code;
    }
    geoip2 /var/lib/GeoIP/GeoLite2-City.mmdb {
        $geoip2_data_city_name      city names en;
        $geoip2_data_region_name    subdivisions 0 names en;
        $geoip2_latitude            location latitude;
        $geoip2_longitude           location longitude;
        $geoip2_postal_code         postal code;
        $geoip2_timezone            location time_zone;
    }
    ...
}
```

---

## Шаг 10. Добавить тестовые заголовки в нужный server/location

Например, в файл виртуального хоста:

```nginx
location / {
    add_header X-Country-Code $geoip2_data_country_code;
    add_header X-City $geoip2_data_city_name;
    add_header X-Region $geoip2_data_region_name;
    add_header X-Latitude   $geoip2_latitude;
    add_header X-Longitude  $geoip2_longitude;
    add_header X-Postal     $geoip2_postal_code;
    add_header X-Timezone   $geoip2_timezone;
    ...
}
```

---

## Примеры: блокировка и редирект по гео-данным

### Пример 1: Редирект по городу

```nginx
if ($geoip2_data_city_name = "Chisinau") {
    return 302 https://gmail.com;
}
```

### Пример 2: Блокировка по городу

```nginx
if ($geoip2_data_city_name = "Chisinau") {
    return 403;
}
```

> Эти блоки добавляются в нужный `server {}` или под конкретный `location {}` ДО proxy_pass!

---
