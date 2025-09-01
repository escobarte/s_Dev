# Production Docker-контейнер для Laravel: от разработки к боевому серверу

## 🎯 Что мы создали

Превратили обычный Laravel проект с **4 отдельными контейнерами** в **один самодостаточный production-ready контейнер**.

### Трансформация проекта:

**ДО (Development):**

```
┌─────────────────────────────────────────┐
│  Docker Compose (4 контейнера)         │
├─────────────────────────────────────────┤
│  📦 nginx     - веб-сервер             │
│  📦 php-fpm   - PHP процессор          │
│  📦 mysql     - база данных            │
│  📦 node      - сборка фронтенда       │
└─────────────────────────────────────────┘
```

**ПОСЛЕ (Production):**

```
┌─────────────────────────────────────────┐
│  Один Docker контейнер                  │
├─────────────────────────────────────────┤
│  🔧 nginx + php-fpm (supervisor)       │
│  📄 SQLite база данных                 │
│  🎨 Готовый фронтенд (CSS/JS)          │
│  ⚙️  Автозапуск и восстановление       │
└─────────────────────────────────────────┘
```

---

## 📁 Финальная структура проекта

```
/opt/professional-laravel-blog/
├── src/                     # Laravel приложение
│   ├── app/
│   ├── public/
│   ├── database/
│   └── ...
├── docker/
│   ├── nginx.conf          # Конфигурация веб-сервера
│   ├── supervisord.conf    # Управление процессами  
│   └── start.sh           # Стартовый скрипт
├── Dockerfile.prod        # Рецепт production образа
└── compose.yaml          # Для локальной разработки (старый)
```

---

## 🏗 Архитектура production контейнера

### Multi-stage сборка (Dockerfile.prod)

```dockerfile
# Этап 1: Сборка фронтенда
FROM node:20-alpine AS node-builder
WORKDIR /app
COPY src/package*.json ./
RUN npm ci --only=production
COPY src/ ./
RUN npm run build

# Этап 2: PHP с расширениями
FROM php:8.3-fpm-alpine AS php-base
RUN apk add --no-cache nginx supervisor [...]
RUN docker-php-ext-install pdo_mysql gd zip [...]

# Этап 3: Финальный образ
FROM php-base AS app
WORKDIR /var/www/html
COPY src/ ./
COPY --from=node-builder /app/public/build ./public/build
RUN composer install --no-dev --optimize-autoloader
```

**Преимущества multi-stage:**

- ✅ **Маленький размер** — dev-зависимости не попадают в финальный образ
- ✅ **Безопасность** — нет исходников npm/composer в production
- ✅ **Скорость** — готовый образ развертывается за секунды

---

## 🔧 Ключевые компоненты

### 1. Supervisor — управление процессами

**Проблема:** Docker контейнер = 1 процесс, но нам нужно nginx + php-fpm одновременно.

**Решение:** Supervisor запускает и мониторит несколько процессов.

```ini
# docker/supervisord.conf
[supervisord]
nodaemon=true

[program:php-fpm]
command=php-fpm --nodaemonize
autostart=true
autorestart=true

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
```

**Результат:** Если один из процессов упадет, supervisor автоматически перезапустит его.

### 2. Nginx внутри контейнера

```nginx
# docker/nginx.conf
server {
    listen 80;
    root /var/www/html/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;  # Локальный PHP-FPM
    }
}
```

**Особенности:**

- ✅ PHP-FPM работает в том же контейнере (`127.0.0.1:9000`)
- ✅ Nginx оптимизирован для production (кеширование статики)
- ✅ Безопасные настройки (скрытие системных файлов)

### 3. SQLite вместо MySQL

**Почему SQLite для production?**

- 🚀 **Простота** — не нужен отдельный сервер базы данных
- 📦 **Портативность** — база внутри контейнера
- ⚡ **Скорость** — для малых и средних проектов быстрее MySQL
- 🔒 **Надежность** — меньше компонентов = меньше точек отказа

**Ограничения:** Не подходит для высоконагруженных приложений с множественными писателями.

---

## 🚀 Стартовый процесс (start.sh)

Скрипт выполняется каждый раз при запуске контейнера:

```bash
#!/bin/bash
set -e

# 1. Создание .env файла для production
cat > /var/www/html/.env << EOF
APP_ENV=production
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite
CACHE_STORE=file
SESSION_DRIVER=file
EOF

# 2. Настройка прав доступа
chown -R www-data:www-data storage bootstrap public
chmod -R 775 storage bootstrap

# 3. Инициализация базы данных (только если не существует)
if [ ! -f /var/www/html/database/database.sqlite ]; then
    touch /var/www/html/database/database.sqlite
    php artisan migrate --force --no-interaction
    php artisan db:seed --force --no-interaction
fi

# 4. Оптимизация Laravel для production
php artisan config:cache
php artisan route:cache  
php artisan view:cache

# 5. Запуск supervisor (nginx + php-fpm)
exec supervisord -c /etc/supervisord.conf
```

**Ключевые особенности:**

- 🔄 **Идемпотентность** — безопасно запускать множество раз
- 🛡️ **Проверки** — не пересоздает базу если она уже есть
- ⚡ **Оптимизация** — кеширует конфигурацию для скорости
- 👤 **Демо-данные** — создает пользователя `demo@demo.com / demodemo`

---

## 💾 Управление данными

### Проблема persistent данных

**Проблема:** При `docker rm` контейнера все данные (база, загруженные файлы) исчезают.

**Решение:** Docker Volumes для хранения важных данных.

```bash
# Создаем именованный volume
docker volume create laravel-db

# Запускаем контейнер с volume
docker run -d --name laravel-blog-prod -p 8080:80 \
  -v laravel-db:/var/www/html/database \
  --restart unless-stopped \
  your-image:latest
```

**Результат:**

- ✅ База данных сохраняется при перезапуске контейнера
- ✅ Можно безопасно обновлять контейнер без потери данных
- ✅ Backup данных = backup Docker volume

### Volume стратегии

```bash
# Только база данных
-v laravel-db:/var/www/html/database

# База + загруженные файлы  
-v laravel-db:/var/www/html/database \
-v laravel-uploads:/var/www/html/storage/app/public

# Полный storage (включая логи)
-v laravel-storage:/var/www/html/storage
```

---

## 🛠 Практическое использование

### Сборка образа

```bash
# Переходим в директорию проекта
cd /opt/professional-laravel-blog

# Собираем production образ
docker build -f Dockerfile.prod -t laravel-blog-prod:v1.0 .

# Проверяем размер образа
docker images | grep laravel-blog-prod
```

### Запуск в production

```bash
# Создаем volume для данных
docker volume create laravel-db

# Запускаем контейнер
docker run -d \
  --name laravel-blog-prod \
  --restart unless-stopped \
  -p 8080:80 \
  -v laravel-db:/var/www/html/database \
  laravel-blog-prod:v1.0

# Проверяем статус
docker ps | grep laravel-blog-prod
```

### Обновление приложения

```bash
# 1. Собираем новую версию
docker build -f Dockerfile.prod -t laravel-blog-prod:v1.1 .

# 2. Останавливаем старую версию  
docker stop laravel-blog-prod
docker rm laravel-blog-prod

# 3. Запускаем новую (данные сохранятся в volume)
docker run -d \
  --name laravel-blog-prod \
  --restart unless-stopped \
  -p 8080:80 \
  -v laravel-db:/var/www/html/database \
  laravel-blog-prod:v1.1
```

---

## 🔍 Мониторинг и диагностика

### Полезные команды

```bash
# Просмотр логов приложения
docker logs laravel-blog-prod -f

# Статус процессов внутри контейнера
docker exec laravel-blog-prod supervisorctl status

# Заход внутрь контейнера для диагностики
docker exec -it laravel-blog-prod sh

# Проверка Laravel логов
docker exec laravel-blog-prod tail -f /var/www/html/storage/logs/laravel.log

# Перезапуск отдельных сервисов
docker exec laravel-blog-prod supervisorctl restart nginx
docker exec laravel-blog-prod supervisorctl restart php-fpm
```

### Health Check

```bash
# Проверка доступности приложения
curl -I http://localhost:8080

# Проверка из другого контейнера
docker run --rm --network host curlimages/curl curl -I http://localhost:8080
```

---

## 🚨 Решение типичных проблем

### 1. Ошибка 502 Bad Gateway

**Причина:** PHP-FPM не запущен или недоступен.

**Решение:**

```bash
docker exec laravel-blog-prod supervisorctl status
docker exec laravel-blog-prod supervisorctl restart php-fpm
```

### 2. Ошибка прав доступа (500 Internal Server Error)

**Причина:** Неправильные права на папки `storage` и `bootstrap`.

**Решение:**

```bash
docker exec laravel-blog-prod chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap
docker exec laravel-blog-prod chmod -R 775 /var/www/html/storage /var/www/html/bootstrap
```

### 3. Потеря данных при перезапуске

**Причина:** Не используются Docker volumes.

**Решение:**

```bash
# Всегда используйте volume для базы данных
docker run -v laravel-db:/var/www/html/database [...]
```

### 4. Контейнер не запускается (Exit Code 137)

**Причина:** Недостаточно памяти или ошибка в start.sh.

**Решение:**

```bash
# Проверяем логи
docker logs laravel-blog-prod

# Увеличиваем память для Docker
# Или исправляем синтаксис в start.sh
```

---

## 🔒 Безопасность production

### Настройки безопасности

```bash
# 1. Пользователь без root привилегий
USER www-data  # В Dockerfile

# 2. Минимальный базовый образ
FROM php:8.3-fpm-alpine  # Alpine вместо Ubuntu

# 3. Только production зависимости
RUN composer install --no-dev --optimize-autoloader

# 4. Скрытие системной информации
server_tokens off;  # В nginx.conf
```

### Production переменные окружения

```bash
# Безопасные настройки в .env
APP_ENV=production
APP_DEBUG=false
LOG_LEVEL=error

# Сложные ключи (генерируются автоматически)
APP_KEY=base64:xxx...
```

---

## 📊 Производительность

### Оптимизации Laravel

```bash
# Кеширование конфигурации (выполняется в start.sh)
php artisan config:cache    # Кеш настроек
php artisan route:cache     # Кеш маршрутов  
php artisan view:cache      # Кеш шаблонов
```

### Оптимизации Nginx

```nginx
# Кеширование статических файлов
location ~* \.(css|js|gif|ico|jpeg|jpg|png)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Gzip сжатие
gzip on;
gzip_types text/css text/javascript application/javascript;
```

### Размер образа

```bash
# Обычно получается:
laravel-blog-prod   latest   150-200MB

# Для сравнения с отдельными контейнерами:
# nginx:alpine       ~15MB
# php:8.3-fpm-alpine ~80MB  
# mysql:8.0          ~500MB
# node:20-alpine     ~170MB
# ИТОГО:             ~765MB vs 200MB
```

---

## 🚀 Масштабирование

### Запуск нескольких экземпляров

```bash
# Экземпляр 1
docker run -d --name laravel-blog-1 -p 8081:80 \
  -v laravel-db-1:/var/www/html/database \
  laravel-blog-prod:latest

# Экземпляр 2  
docker run -d --name laravel-blog-2 -p 8082:80 \
  -v laravel-db-2:/var/www/html/database \
  laravel-blog-prod:latest

# Load Balancer (nginx)
upstream laravel_backend {
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;
}
```

### Для высоконагруженных проектов

Можно заменить SQLite на внешнюю MySQL:

```bash
docker run -d --name laravel-blog-prod \
  -p 8080:80 \
  -e DB_CONNECTION=mysql \
  -e DB_HOST=mysql.example.com \
  -e DB_DATABASE=laravel_prod \
  -e DB_USERNAME=laravel \
  -e DB_PASSWORD=secret \
  laravel-blog-prod:latest
```

---

## 📚 Заключение

### Что мы достигли:

✅ **Простота развертывания** — один контейнер вместо четырех  
✅ **Надежность** — автоматический перезапуск упавших процессов  
✅ **Портативность** — работает на любом сервере с Docker  
✅ **Быстрота** — запуск за 10-15 секунд  
✅ **Безопасность** — production настройки из коробки  
✅ **Персистентность** — данные сохраняются при обновлениях  

### Production-ready особенности:

🔧 **Multi-stage build** — оптимальный размер образа  
🔄 **Supervisor** — управление процессами  
📄 **SQLite** — простота базы данных  
🛡️ **Security hardening** — безопасные настройки  
⚡ **Performance** — кеширование и оптимизации  
📊 **Monitoring** — логи и health checks  

**Результат:** Профессиональное Docker-решение готовое для production использования! 🎉

---

## 📖 Дополнительные материалы

### Команды для ежедневного использования

```bash
# Деплой новой версии
./deploy.sh v1.2

# Бэкап данных  
docker run --rm -v laravel-db:/source -v $(pwd):/backup \
  alpine tar czf /backup/laravel-backup-$(date +%Y%m%d).tar.gz -C /source .

# Просмотр логов в реальном времени
docker logs laravel-blog-prod -f --tail 100

# Мониторинг ресурсов
docker stats laravel-blog-prod
```

Теперь у вас есть полное понимание как создать и поддерживать production-ready Laravel контейнер! 🚀