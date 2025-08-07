# Настройка GeoIP2 в NGINX для добавления заголовков с геоданными

## Конфигурация GeoIP2 в nginx.conf

```nginx
# Подключение базы GeoLite2-City
geoip2 /var/lib/GeoIP/GeoLite2-City.mmdb {
    $geoip2_city         city names en;                 # Название города (на английском)
    $geoip2_region       subdivisions 0 names en;       # Название региона (subdivision) — первая запись
    $geoip2_postal_code  postal code;                   # Почтовый индекс
    $geoip2_latitude     location latitude;             # Широта местоположения
    $geoip2_longitude    location longitude;            # Долгота местоположения
    $geoip2_timezone     location time_zone;            # Часовой пояс
}

# Подключение базы GeoLite2-ASN
geoip2 /var/lib/GeoIP/GeoLite2-ASN.mmdb {
    $geoip2_asn autonomous_system_number;               # Номер автономной системы (ASN)
    $geoip2_isp autonomous_system_organization;         # Название организации (провайдера)
}
```

## Пример использования в блоке location

```nginx
location / {
    add_header X-City       $geoip2_city;               # Заголовок с названием города
    add_header X-Region     $geoip2_region;             # Заголовок с регионом
    add_header X-Postal     $geoip2_postal_code;        # Заголовок с почтовым индексом
    add_header X-Latitude   $geoip2_latitude;           # Заголовок с широтой
    add_header X-Longitude  $geoip2_longitude;          # Заголовок с долготой
    add_header X-Timezone   $geoip2_timezone;           # Заголовок с часовым поясом
    add_header X-ASN        $geoip2_asn;                # Заголовок с номером ASN
    add_header X-ISP        $geoip2_isp;                # Заголовок с названием провайдера
}
```

## Дополнительно

- Убедитесь, что у вас установлены библиотеки и модуль `ngx_http_geoip2_module`.
- Базы данных `.mmdb` можно получить бесплатно с сайта MaxMind: https://dev.maxmind.com/geoip/geolite2/
- После изменения конфигурации не забудьте выполнить:

```bash
nginx -t  # Проверка конфигурации
systemctl reload nginx  # Применение изменений
```
