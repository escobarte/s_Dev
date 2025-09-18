#!/bin/bash
set -e

echo "Запускаем Laravel приложение..."

# Создаём .env для production с SQLite
cat > /var/www/html/.env << EOF
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=http://localhost

DB_CONNECTION=sqlite
DB_DATABASE=/var/www/html/database/database.sqlite

CACHE_STORE=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

BROADCAST_CONNECTION=log
LOG_CHANNEL=stderr
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error
EOF

# Исправляем права доступа
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Создаём SQLite базу данных
mkdir -p /var/www/html/database
touch /var/www/html/database/database.sqlite
chown www-data:www-data /var/www/html/database/database.sqlite

# Очищаем кеш
php artisan config:clear
php artisan cache:clear 2>/dev/null || echo "Не удалось очистить кеш, пропускаем..."
php artisan view:clear

# Генерируем ключ
php artisan key:generate --no-interaction --force

# Запускаем миграции
php artisan migrate --force --no-interaction 2>/dev/null || echo "Миграции не выполнены"

php artisan db:seed --force --no-interaction 2>/dev/null || echo "Сиды не выполнены"

# Оптимизируем для production
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Запускаем supervisor для управления nginx и php-fpm..."
exec supervisord -c /etc/supervisord.conf
