#!/bin/bash
# Shebang - указывает системе использовать bash для выполнения скрипта

# Включаем строгий режим: скрипт завершится при первой ошибке
# Без этой опции скрипт продолжил бы выполнение даже после сбоев
set -e

echo "Запускаем Laravel приложение..."

# Создаём файл .env для production окружения с настройками SQLite
# cat > файл << EOF создает файл и записывает в него всё до строки EOF
cat > /var/www/html/.env << EOF
APP_NAME=Laravel              # Название приложения
APP_ENV=production           # Окружение (production = продакшн)
APP_KEY=                     # Ключ шифрования (будет сгенерирован позже)
APP_DEBUG=false              # Отключаем отладку в продакшне (скрываем ошибки от пользователей)
APP_TIMEZONE=UTC             # Часовой пояс UTC
APP_URL=http://localhost     # URL приложения

DB_CONNECTION=sqlite         # Используем SQLite как базу данных
DB_DATABASE=/var/www/html/database/database.sqlite  # Путь к файлу SQLite БД

CACHE_STORE=file            # Кеш хранится в файлах
FILESYSTEM_DISK=local       # Файлы сохраняются локально
QUEUE_CONNECTION=sync       # Очереди выполняются синхронно (сразу)
SESSION_DRIVER=file         # Сессии хранятся в файлах
SESSION_LIFETIME=120        # Время жизни сессии 120 минут

BROADCAST_CONNECTION=log    # События рассылки записываются в логи
LOG_CHANNEL=stderr          # Логи выводятся в stderr (стандартный поток ошибок)
LOG_STACK=single           # Используем один лог-файл
LOG_DEPRECATIONS_CHANNEL=null  # Отключаем логи устаревших функций
LOG_LEVEL=error            # Записываем только ошибки (не info, не debug)
EOF

# Исправляем права доступа для критически важных директорий Laravel
# chown меняет владельца файлов на www-data (пользователь веб-сервера)
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
# chmod устанавливает права: 775 = rwxrwxr-x (владелец и группа могут всё, остальные только читать)
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Создаём директорию для базы данных SQLite
mkdir -p /var/www/html/database
# Создаём пустой файл базы данных SQLite
touch /var/www/html/database/database.sqlite
# Назначаем владельцем файла БД пользователя веб-сервера
chown www-data:www-data /var/www/html/database/database.sqlite

# Очищаем различные виды кеша Laravel перед настройкой
# Очищаем кеш конфигурации
php artisan config:clear
# Очищаем общий кеш приложения (с обработкой ошибки)
# 2>/dev/null скрывает сообщения об ошибках
# || echo выполнится если команда завершится с ошибкой
php artisan cache:clear 2>/dev/null || echo "Не удалось очистить кеш, пропускаем..."
# Очищаем кеш скомпилированных Blade шаблонов
php artisan view:clear

# Генерируем секретный ключ для шифрования данных приложения
# --no-interaction: не запрашивать подтверждение пользователя
# --force: принудительно перезаписать существующий ключ
php artisan key:generate --no-interaction --force

# Выполняем миграции базы данных (создаём таблицы)
# --force: выполнить в продакшн окружении без подтверждения
# --no-interaction: не запрашивать подтверждение
php artisan migrate --force --no-interaction 2>/dev/null || echo "Миграции не выполнены"

# Заполняем базу данных начальными данными (seeders)
php artisan db:seed --force --no-interaction 2>/dev/null || echo "Сиды не выполнены"

# Оптимизируем приложение для продакшн среды
# Кешируем конфигурацию в один файл для быстрого доступа
php artisan config:cache
# Кешируем все роуты для ускорения маршрутизации
php artisan route:cache
# Компилируем все Blade шаблоны заранее
php artisan view:cache

echo "Запускаем supervisor для управления nginx и php-fpm..."
# exec заменяет текущий процесс на supervisord
# supervisord будет управлять запуском nginx и php-fpm процессов
exec supervisord -c /etc/supervisord.conf