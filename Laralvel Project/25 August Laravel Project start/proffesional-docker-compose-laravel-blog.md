> **Structure:**
> **src/** — сюда позже положим код Laravel (или склонируем репо).
> **nginx/default.conf** — наш конфиг веб-сервера (root → /public).
> **docker/php/Dockerfile** — свой образ php-fpm с расширениями и composer.
> **compose.yaml** - web+php+db+node

mkdir -p /opt/proffesional-laravel-blog/{src,nginx,docker/php}
chown -R $USER:$USER /opt/proffesional-laravel-blog
find /opt/proffesional-laravel-blog -maxdepth 2 -type d | sort
cd /opt/proffesional-laravel-blog
git clone https://github.com/guillaumebriday/laravel-blog.git src
cp src/.env.example src/.env
ls -1 src | egrep 'artisa|public|routes' || true

nano nginx/defaul.conf
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
nano compose.yaml
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
nano src/.env
```
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
DB_CONNECTION=mysql
CACHE_STORE=file
QUEUE_CONNECTION=sync
```
grep -E '^(DB_CONNECTION|DB_HOST|DB_PORT|DB_DATABASE|DB_USERNAME|DB_PASSWORD|CACHE_STORE|QUEUE_CONNECTION)=' src/.env

docker compose up -d --build
docker compose ps

docker compose exec php sh -lc 'cd /var/www/html && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction --prefer-dist'
docker compose exec php sh -lc 'cd /var/www/html && ls -ld vendor && php artisan --version'

docker compose exec php sh -lc 'cd /var/www/html && php artisan key:generate'
```
docker compose exec php sh -lc '
  cd /var/www/html &&
  mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache &&
  chown -R www-data:www-data storage bootstrap/cache &&
  chmod -R ug+rwX storage bootstrap/cache &&
  php artisan config:clear && php artisan cache:clear && php artisan view:clear
  '
docker compose exec php sh -lc '
  cd /var/www/html &&
  (grep -q "^CACHE_STORE=" .env || echo "CACHE_STORE=file" >> .env) &&
  sed -i "s/^CACHE_STORE=.*/CACHE_STORE=file/" .env &&
  (grep -q "^SESSION_DRIVER=" .env || echo "SESSION_DRIVER=file" >> .env) &&
  (grep -q "^QUEUE_CONNECTION=" .env || echo "QUEUE_CONNECTION=sync" >> .env) &&
  php artisan optimize:clear
'
```

docker compose run --rm node sh -lc 'cd /var/www/html && if [ -f package-lock.json ]; then npm ci; else npm install; fi && npm run build'
docker compose exec php sh -lc 'cd /var/www/html && php artisan migrate:fresh --seed'