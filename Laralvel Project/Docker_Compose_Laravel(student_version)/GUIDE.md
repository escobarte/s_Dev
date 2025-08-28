#### Берём готовый проект guillaumebriday/laravel-blog. всё сделаем только через Docker Compose.

#### Работаем на 10.100.93.7. Путь проекта: /opt/laravel-blog.

#### Цель: открыть сайт, зайти в /login, попасть в админку.

> **Мини-пояснение:**
> **src/** — сюда позже положим код Laravel (или склонируем репо).
> **nginx/default.conf** — наш конфиг веб-сервера (root → /public).
> **docker/php/Dockerfile** — свой образ php-fpm с расширениями и composer.

#### Step 1: Folder Structure

```
sudo mkdir -p /opt/laravel-blog/{src,nginx,docker/php}                 #create folders structure
sudo chown -R $SUDO_USER:$SUDO_USER /opt/laravel-blog                #set permissions for this foler as $USER
find /opt/laravel-blog -maxdepth 2 -type d | sort                    #list info about dirrectory
```

#### Step 2: nginx/default.conf

nano default.conf

```
server {
  listen 80;
  server_name _;

  root /var/www/html/public;
  index index.php index.html;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
  }

  location ~ \.php$ {
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_pass php:9000;
    fastcgi_index index.php;
  }

  location ~ /\.(?!well-known) {
    deny all;
  }
}
```

ls -l default.conf
`grep -nE 'root|try_files|fastcgi_pass' default.conf             # find searched wrods in default.conf`

#### Step 3: DOCKERFILE for php-fpm (dependecies + composer)

nano docker/php/Dockerfile

```
# image php+fpm
FROM php:8.3-fpm-alpine

#utilities and dev packages
RUN apk add --no-cache \
    bash git curl unzip icu-libs oniguruma libxml2 libzip \
    libpng libjpeg-turbo libwebp freetype \
    && apk add --no-cache --virtual .build-deps \
    build-base icu-dev oniguruma-dev libxml2-dev libzip-dev zlib-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev

#build and enabling extensions:
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
 && docker-php-ext-install -j"$(nproc)" \
    pdo_mysql mbstring exif pcntl bcmath gd intl zip \
 && apk del --no-network .build-deps

#compose install
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html
```

`pdo_mysql` — это драйвер для подключения PHP (через PDO) к MySQL. Без него Laravel не сможет разговаривать с БД.
`intl` (библиотека ICU) — даёт «умные» операции с текстами/датами/числами по локалям (напр. корректная сортировка, форматы дат/валют).
`Composer` — это менеджер PHP-зависимостей, ему нужен `сам PHP` и его расширения (как раз те, что мы ставим в php)

#### Step 4: compose.yaml

`Описываем стек из 2 сервисов web + php`

```
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/html/www:ro # code is compiling only for reading-
      - ./nginx:/etc/nginx/conf.d/:ro #nginx confing read only
    depends_on:
      php: # awwaiting PHP be ready first
        condition: service_healthy
    restart: unless-stopped

  php:
    build:
      context: ./docker/php #dockerfile that i prepared
      dockerfile: Dockerfile
    volumes:
       - ./src:/var/www/html
    healthcheck:
      test: ["CMD", "php", "-v"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped
```

docker compose config

#### Step 5: running web+php simple test (no db)

A) [Not Mandatory just for Test connections]
Let's create and index.php php info
mkdir -p /opt/laravel-blog/src/public
nano /opt/laravel-blog/src/public/index.php
`<?php phpinfo();`

docker compose up -d --build
docker compose ps

*/ access on web 10.100.93.7:8080 /*

---------------------------------------------------------------

#### Issues.

1. Incorrect: * Synctax, paths, variables, nginx configs 
   **User**

> 1) Убедимся, что Nginx использует *root=/var/www/html/public*
>    `docker compose exec web sh -lc 'grep -n "root /var/www/html/public" /etc/nginx/conf.d/default.conf || echo NO_ROOT_LINE'`
> 2) Файл index.php виден в web?
>    `docker compose exec web sh -lc 'ls -l /var/www/html/public/index.php || echo NO_INDEX_WEB'`
> 3) Тот же файл виден в php?
>    `docker compose exec php sh -lc 'ls -l /var/www/html/public/index.php || echo NO_INDEX_PHP'`
>    `curl -sI http://127.0.0.1:8080/ | head -n1`
>    `curl -s http://127.0.0.1:8080/index.php | grep -i "php version" -m1 || true`
>    `docker compose up -d --force-recreate web`
>    `docker compose logs --no-color -n 50 web`
>    `docker compose up -d --force-recreate web`
>    `docker compose exec web sh -lc 'nginx -t'`

---------------------------------------------------------------

#### Cloning project

```
cd /opt/laravel-project
rm -rf src/*
git clone <github address project> src
ls -1 src | egrep 'artisa|public|routes' || true
```

#### Composer install

```
cd /opt/laravel-blog
docker compose exec php sh -lc 'cd /var/www/html && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction --prefer-dist'
docker compose exec php sh -lc 'cd /var/www/html && ls -ld vendor && php artisan --version'
```

#### Updated (db added) compose.yaml

```
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/html/www:ro # code is compiling only for reading-
      - ./nginx:/etc/nginx/conf.d/:ro #nginx confing read only
    depends_on:
      php: # awwaiting PHP be ready first
        condition: service_healthy
    restart: unless-stopped

  php:
    build:
      context: ./docker/php #dockerfile that i prepared
      dockerfile: Dockerfile
    volumes:
       - ./src:/var/www/html
    healthcheck:
      test: ["CMD", "php", "-v"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_USER:  laravel
      MYSQL_PASSWORD: laravel
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "127.0.0.1", "-proot"]
      interval: 10s
      timeout: 5s
      retries: 10
    restart: unless-stopped

volumes:
  db_data:
```

> Коротко что мы сделали сейчас:
> Добавили сервис db (MySQL) в compose.yaml.
> 
> > При первом старте MySQL создаёт БД/пользователя из переменных MYSQL_*.
> > db_data — том, чтобы данные БД не пропадали при пересоздании контейнера.
> > Порт наружу не открывали: БД доступна только внутри сети Compose по имени db.
> > web и php могут подключаться к БД по адресу db:3306

#### .env Configure && APP_KEY generate
```
cd /opt/laravel-blog/src
cp .env.example .env
```
`nano .env`
```
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
DB_CONNECTION=mysql
```
grep -E '^(DB_CONNECTION|DB_HOST|DB_PORT|DB_DATABASE|DB_USERNAME|DB_PASSWORD)=' .env

**APP_KEY Generating**
`docker compose exec php sh -lc 'cd /var/www/html && php artisan key:generate'`
`docker compose exec php sh -lc 'cd /var/www/html && grep ^APP_KEY= .env'`
*APP_KEY=base64:fz7IX9QSbqc3rq+08cqqvS4FjoPcVIzF02svOKQZh34=*

#### Migration + Seeds (creating demo user)
**Repairing rights (/storage, boostrap/cache)**
```
cd /opt/laravel-blog
docker compose exec php sh -lc '
  cd /var/www/html &&
  mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache &&
  chown -R www-data:www-data storage bootstrap/cache &&
  chmod -R ug+rwX storage bootstrap/cache &&
  php artisan config:clear && php artisan cache:clear && php artisan view:clear
  '
  ```
**File-Cache + cleaning cache**
```
cd /opt/laravel-blog
docker compose exec php sh -lc '
  cd /var/www/html &&
  # гарантируем нужные настройки
  (grep -q "^CACHE_STORE=" .env || echo "CACHE_STORE=file" >> .env) &&
  sed -i "s/^CACHE_STORE=.*/CACHE_STORE=file/" .env &&
  (grep -q "^SESSION_DRIVER=" .env || echo "SESSION_DRIVER=file" >> .env) &&
  (grep -q "^QUEUE_CONNECTION=" .env || echo "QUEUE_CONNECTION=sync" >> .env) &&
  # чистим все кэши / конфиги
  php artisan optimize:clear
'
```
**Artisan Migrate Fresh**
`docker compose exec php sh -lc 'cd /var/www/html && php artisan migrate:fresh --seed'`

#### Updated compose.yaml [Final](web+php+db+node) {NodeJs added}
```
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./src:/var/www/html:ro
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      php: # awwaiting PHP be ready first
        condition: service_healthy
    restart: unless-stopped

  php:
    build:
      context: ./docker/php #dockerfile that i prepared
      dockerfile: Dockerfile
    volumes:
       - ./src:/var/www/html
    healthcheck:
      test: ["CMD", "php", "-v"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_USER:  laravel
      MYSQL_PASSWORD: laravel
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "127.0.0.1", "-proot"]
      interval: 10s
      timeout: 5s
      retries: 10
    restart: unless-stopped

  node:
    image: node:20-alpine
    working_dir: /var/www/html
    volumes:
      - ./src:/var/www/html

volumes:
  db_data:
```
**Issue meet with volumes**
*Update compose.yaml* **update paht of volumes**
```
    volumes:
      - ./src:/var/www/html:ro
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
```

**Recreate web service and check**
`docker compose up -d --force-recreate web`
`docker compose exec web sh -lc 'ls -ld /var/www/html /var/www/html/public /var/www/html/public/build || true; ls -l /var/www/html/public/build/manifest.json || echo NO_MANIFEST_IN_WEB'`


