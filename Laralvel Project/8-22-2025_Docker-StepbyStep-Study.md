### Проверка, что Docker/Compose стоят

```
docker --version            # Должна быть версия Docker, иначе ставим Docker
docker compose version      # Должна быть версия Compose v2 (встроен в docker)
```

### Долгоживущий контейнер Nginx + публикация порта

```
docker run -d --name web -p 8080:80 nginx:alpine  # -d фон, -p наружу 8080→внутрь 80
docker ps --filter name=web                        # Убедиться, что контейнер работает
curl -sI http://127.0.0.1:8080 | head -n1         # Должно быть HTTP/1.1 200 OK
docker rm -f web                                   # Приберём, чтобы не мешал дальше
```

### Bind-mount: контейнер читает файлы с хоста

```
# Готовим контент на ХОСТЕ (вне контейнера)
mkdir -p /opt/nginx-demo/html

# Создаём страницу
cat >/opt/nginx-demo/html/index.html <<'HTML'
<!doctype html>
<title>Bind mount demo</title>
<h1>Hello from bind mount</h1>
<p>Nginx читает файлы из папки хоста.</p>
HTML

# Запускаем Nginx и монтируем папку: ХОСТ:/opt/nginx-demo/html → КОНТЕЙНЕР:/usr/share/nginx/html
docker run -d --name web -p 8080:80 \
  -v /opt/nginx-demo/html:/usr/share/nginx/html:ro \
  nginx:alpine

curl -s http://127.0.0.1:8080 | head -n3   # Должно показать наш <h1> из хоста
docker rm -f web
```

> bind-mount даёт контейнеру доступ к файлам с хоста; :ro — только чтение.

### Docker Compose (1 сервис: web)

```
# Стек «compose-demo»
mkdir -p /opt/compose-demo/html
cat >/opt/compose-demo/html/index.html <<'HTML'
<!doctype html>
<title>Compose demo</title>
<h1>Compose is working</h1>
<p>Served by Nginx via Docker Compose.</p>
HTML

# Файл compose.yaml — декларация сервиса web
cat >/opt/compose-demo/compose.yaml <<'YAML'
services:
  web:                       # имя сервиса → станет DNS-именем внутри сети Compose
    image: nginx:alpine      # образ, из которого запустим контейнер
    ports:
      - "8080:80"            # публикация наружу: порт 8080 хоста → 80 контейнера
    volumes:
      - ./html:/usr/share/nginx/html:ro   # наш статический контент (только чтение)
    restart: unless-stopped   # авто-перезапуск, кроме ручной остановки
YAML

cd /opt/compose-demo
docker compose up -d          # поднять весь стек по декларации
docker compose ps             # список контейнеров стека
curl -s http://127.0.0.1:8080 | head -n3   # видим "Compose is working"
```

### Сеть Compose + reverse-proxy: Nginx → API

```
cd /opt/compose-demo
docker compose down    # остановим прошлый стек, чтобы чисто обновить конфиг

# Конфиг Nginx: статик из /usr/share/nginx/html и прокси /api → на сервис "api"
cat > nginx.conf <<'NGINX'
server {
  listen 80;
  server_name _;
  root /usr/share/nginx/html;

  location / {
    try_files $uri $uri/ =404;
  }

  # Все запросы на /api отправляем на внутренний сервис "api" порт 5678
  location /api {
    proxy_pass http://api:5678/;          # "api" — это ИМЯ СЕРВИСА из Compose (внутренний DNS)
    proxy_set_header Host $host;          # пробрасываем заголовки (стандартная практика)
    proxy_set_header X-Real-IP $remote_addr;
  }
}
NGINX

# Обновляем compose.yaml: добавляем сервис api и монтируем nginx.conf в web
cat > compose.yaml <<'YAML'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro                     # статический контент
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro      # наш конфиг Nginx
    depends_on:
      - api                                                 # порядок старта (api раньше)
    restart: unless-stopped

  api:
    image: hashicorp/http-echo:1.0.0
    command: ["-text=Hello from API via Compose", "-listen=:5678"]  # простой echo-сервер
    restart: unless-stopped
YAML

docker compose config                 # валидация YAML (ловим опечатки типа dependes_on)
docker compose up -d --force-recreate # пересоздать с новым конфигом
curl -s http://127.0.0.1:8080/api     # Ожидаем: "Hello from API via Compose"
```

> Compose создаёт общую сеть, где сервисы видят друг друга по имени (DNS внутри сети).
> api наружу не открыт (нет ports), но доступен Nginx через proxy_pass http://api:5678.

### Добавляем PHP-FPM: Nginx отдаёт статик и исполняет .php

```
cd /opt/compose-demo
docker compose down

# Код PHP: диагностическая страница
mkdir -p php
cat > php/index.php <<'PHP'
<?php phpinfo();
PHP

# Конфиг Nginx для PHP (fastcgi → php:9000) + оставляем /api прокси
cat > nginx.conf <<'NGINX'
server {
  listen 80;
  server_name _;

  root /var/www/html;                   # где лежит код в контейнере web
  index index.php index.html;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
  }

  location ~ \.php$ {
    include        /etc/nginx/fastcgi_params;
    fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;  # полный путь к .php
    fastcgi_pass   php:9000;              # отправляем в сервис "php" порт 9000 (внутренняя сеть)
    fastcgi_index  index.php;
  }

  location /api {
    proxy_pass http://api:5678/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
NGINX

# Обновляем compose.yaml: добавляем сервис php (php-fpm)
cp compose.yaml compose.yaml.bak
cat > compose.yaml <<'YAML'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./php:/var/www/html:ro                    # код виден Nginx (только чтение)
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - api
      - php
    restart: unless-stopped

  php:
    image: php:8.3-fpm-alpine                     # правильный тег (не "php8.3-...")
    volumes:
      - ./php:/var/www/html                       # код виден php-fpm (чтение/запись)
    healthcheck:                                  # простой healthcheck для мониторинга
      test: ["CMD", "php", "-v"]
      interval: 10s
      timeout: 3s
      retries: 3

  api:
    image: hashicorp/http-echo:1.0.0
    command: ["-text=Hello from API via Compose", "-listen=:5678"]
    restart: unless-stopped
YAML

docker compose config
docker compose up -d --force-recreate
curl -sI http://127.0.0.1:8080/index.php | head -n1    # Ждём HTTP/1.1 200 OK
# Если хочешь посмотреть внутренний /api из web-контейнера:
docker compose exec web sh -c "wget -qO- http://api:5678"
```

> Nginx не исполняет PHP сам — он передаёт .php в php-fpm (сервис php) по внутренней сети.
> Обеим службам монтируем один и тот же код (./php), чтобы Nginx мог читать файлы, а php-fpm — исполнять.

```
[web:nginx] --(root=/var/www/html/public)--> статик / index.php
     |                                   \
     | fastcgi_pass php:9000               \ proxy /api (если надо)
     v
[php:fpm] (видит ВЕСЬ /var/www/html → Laravel)
     |
     | PDO MySQL
     v
[db:mysql] (внутренняя сеть, без публикации портов наружу)
```

### 

```

```

### 

```

```

### 

```

```

### 

```

```
