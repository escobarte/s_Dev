# Полный DevOps гайд для начинающих - Laravel Blog проект

## ВВЕДЕНИЕ: Что мы изучаем?

Мы анализируем Laravel проект с точки зрения DevOps инженера. Наша задача - понять:
- Что нужно этому приложению для работы
- Как его собрать и развернуть 
- Как автоматизировать этот процесс

---

## ЭТАП 1: СИСТЕМНЫЕ ТРЕБОВАНИЯ - "Что кушает наш зверь?"

### 🎯 Цель: Понять технические зависимости проекта

### 📁 Какие файлы изучать:
1. **`composer.json`** - главный файл зависимостей PHP
2. **`package.json`** - зависимости для фронтенда (JavaScript/CSS)
3. **`.env.example`** - шаблон настроек окружения

### 🔍 Что ищем в `composer.json`:

#### Секция `"require"` (обязательные зависимости):
```json
{
  "require": {
    "php": "^8.3",                    // ← Минимальная версия PHP
    "laravel/framework": "^11.28",    // ← Версия Laravel
    "predis/predis": "2.2.2",        // ← Нужен Redis
    "doctrine/dbal": "4.2.1",        // ← Работа с БД
    "pusher/pusher-php-server": "7.2.6" // ← Real-time уведомления
  }
}
```

**Что это означает для DevOps:**
- На сервере должен быть PHP 8.3 или выше
- Нужен Redis сервер
- Нужна база данных (MySQL/PostgreSQL)
- Возможно потребуется Pusher или альтернатива

#### Секция `"require-dev"` (только для разработки):
```json
{
  "require-dev": {
    "phpunit/phpunit": "11.4.1",     // ← Для тестов
    "laravel/pint": "1.18.1",        // ← Проверка стиля кода
    "mockery/mockery": "1.6.12"      // ← Для моков в тестах
  }
}
```

**Что это означает:** Эти пакеты не нужны на продакшн сервере, только для разработки и CI/CD.

### 🔍 Что ищем в `package.json`:
```json
{
  "devDependencies": {
    "bootstrap": "^5.3.0",           // ← CSS фреймворк
    "sass": "^1.77.0",              // ← Компилятор CSS
    "@hotwired/turbo": "^8.0.4"     // ← JavaScript библиотека
  }
}
```

**Что это означает:** Нужен Node.js и npm/yarn для сборки фронтенда.

---

## ЭТАП 2: ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ - "Настройки для жизни"

### 📁 Файл для изучения: `.env.example`

Этот файл показывает, какие настройки нужны приложению. Вот ключевые секции:

### 🗄️ База данных:
```env
DB_CONNECTION=mysql              # ← Тип БД (mysql, pgsql, sqlite)
DB_HOST=127.0.0.1               # ← Адрес сервера БД
DB_PORT=3306                    # ← Порт БД
DB_DATABASE=laravel_blog        # ← Название базы
DB_USERNAME=root                # ← Пользователь БД
DB_PASSWORD=                    # ← Пароль БД
```

### 🚀 Redis (кэш и очереди):
```env
REDIS_HOST=127.0.0.1            # ← Адрес Redis сервера
REDIS_PASSWORD=null             # ← Пароль Redis
REDIS_PORT=6379                 # ← Порт Redis
```

### 📧 Email:
```env
MAIL_MAILER=smtp                # ← Способ отправки почты
MAIL_HOST=mailpit               # ← SMTP сервер
MAIL_PORT=1025                  # ← SMTP порт
```

### 🔐 Безопасность:
```env
APP_KEY=                        # ← Ключ шифрования (ВАЖНО!)
APP_ENV=local                   # ← Режим (local/staging/production)
APP_DEBUG=true                  # ← Отладка (false в продакшне!)
```

---

## ЭТАП 3: АРХИТЕКТУРА СИСТЕМЫ - "Из чего состоит решение"

### 🏗️ Компоненты системы:

#### 1. **Web сервер** (входная точка):
- **Nginx** - рекомендуется (проксирует запросы к PHP)
- **Apache** - альтернатива

#### 2. **PHP процессор**:
- **PHP-FPM** - обрабатывает PHP код
- Версия: 8.3+
- Расширения: pdo, redis, gd, zip, xml

#### 3. **База данных**:
- **MySQL 8.0+** или **PostgreSQL 13+**
- Для хранения данных приложения

#### 4. **Redis сервер**:
- Кэширование данных
- Хранение сессий
- Очереди заданий

#### 5. **Фоновые процессы**:
- **Laravel Horizon** - управление очередями
- **Supervisor** - мониторинг процессов

### 📊 Схема архитектуры:
```
Пользователь → Nginx → PHP-FPM → Laravel App
                                      ↓
                                 MySQL БД
                                      ↓
                                  Redis
                                      ↓
                              Laravel Horizon
```

---

## ЭТАП 4: ПРОЦЕСС СБОРКИ - "Как готовить блюдо"

### 🎯 Последовательность команд для подготовки приложения:

#### 1. **Подготовка сервера**:
```bash
# Обновление системы
apt update && apt upgrade -y

# Установка PHP 8.3
apt install php8.3 php8.3-fpm php8.3-mysql php8.3-redis php8.3-gd php8.3-zip php8.3-xml

# Установка Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Установка Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install nodejs

# Установка Redis
apt install redis-server
```

#### 2. **Сборка приложения**:
```bash
# Клонирование проекта
git clone https://github.com/guillaumebriday/laravel-blog.git
cd laravel-blog

# Установка PHP зависимостей
composer install --no-dev --optimize-autoloader

# Копирование настроек
cp .env.example .env

# Генерация ключа приложения
php artisan key:generate

# Установка фронтенд зависимостей
npm install

# Компиляция фронтенда
npm run build
```

#### 3. **Настройка Laravel**:
```bash
# Кэширование конфигурации
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Создание символической ссылки для файлов
php artisan storage:link

# Миграции базы данных
php artisan migrate --force

# Установка дополнительных пакетов
php artisan horizon:install
php artisan telescope:install
```

---

## ЭТАП 5: КОНФИГУРАЦИЯ СЕРВИСОВ

### 🌐 Nginx конфигурация (`/etc/nginx/sites-available/laravel-blog`):
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/laravel-blog/public;
    
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### 🔄 Supervisor конфигурация (`/etc/supervisor/conf.d/horizon.conf`):
```ini
[program:horizon]
process_name=%(program_name)s
command=php /var/www/laravel-blog/artisan horizon
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/laravel-blog/horizon.log
stopwaitsecs=3600
```

---

## ЭТАП 6: ТЕСТИРОВАНИЕ И ПРОВЕРКИ

### 🧪 Команды для проверки:

#### Проверка работы приложения:
```bash
# Запуск тестов
php artisan test

# Проверка стиля кода
./vendor/bin/pint --test

# Проверка конфигурации
php artisan config:show

# Проверка подключений
php artisan tinker
> DB::connection()->getPdo();
> Redis::ping();
```

#### Проверка сервисов:
```bash
# Статус PHP-FPM
systemctl status php8.3-fpm

# Статус Nginx
systemctl status nginx

# Статус Redis
systemctl status redis

# Статус Supervisor
systemctl status supervisor
```

---

## ЭТАП 7: МОНИТОРИНГ И ЛОГИ

### 📊 Что мониторить:

#### Файлы логов:
- Laravel: `/var/www/laravel-blog/storage/logs/laravel.log`
- Nginx: `/var/log/nginx/error.log`
- PHP-FPM: `/var/log/php8.3-fpm.log`
- Supervisor: `/var/log/supervisor/supervisord.log`

#### Web интерфейсы:
- **Horizon Dashboard**: `http://your-domain/horizon`
- **Telescope** (только dev): `http://your-domain/telescope`

#### Системные метрики:
- CPU и RAM использование
- Дисковое пространство
- Сетевые подключения
- Статус процессов

---

## ЭТАП 8: БЕЗОПАСНОСТЬ

### 🔒 Критически важные настройки:

#### В `.env` файле:
```env
APP_ENV=production              # ← НЕ local или staging
APP_DEBUG=false                 # ← НЕ true в продакшне!
APP_KEY=base64:длинный-ключ     # ← Уникальный для каждого проекта
```

#### Права доступа к файлам:
```bash
# Владелец файлов
chown -R www-data:www-data /var/www/laravel-blog

# Права на папки
find /var/www/laravel-blog -type d -exec chmod 755 {} \;

# Права на файлы  
find /var/www/laravel-blog -type f -exec chmod 644 {} \;

# Права на исполняемые файлы
chmod +x /var/www/laravel-blog/artisan
```

---

## ЭТАП 9: CI/CD PIPELINE СТРУКТУРА

### 🔄 Этапы автоматизации:

#### 1. **Test Stage** (проверки):
- Запуск `php artisan test`
- Проверка `./vendor/bin/pint`
- Валидация `.env` файлов

#### 2. **Build Stage** (сборка):
- `composer install --no-dev`
- `npm ci && npm run build`
- Создание Docker образа

#### 3. **Deploy Stage** (развертывание):
- Загрузка на сервер
- Обновление кода
- Запуск миграций
- Перезапуск сервисов

#### 4. **Health Check** (проверка работы):
- HTTP проверки
- Проверка БД подключения
- Проверка очередей

---

## СЛЕДУЮЩИЕ ШАГИ

После изучения этого гайда, вы должны:
1. Понимать, какие сервисы нужны Laravel приложению
2. Знать, как настроить сервер для Laravel
3. Понимать процесс сборки и развертывания
4. Быть готовыми к написанию CI/CD pipeline

**Готовы перейти к практике?**