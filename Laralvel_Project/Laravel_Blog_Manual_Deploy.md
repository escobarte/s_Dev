# Laravle Deploy Guide --version 2.0

*This guide include how to setup laravel env, and deploy project*
*Will be used project from git*
`https://github.com/guillaumebriday/laravel-blog?tab=readme-ov-file`

> Importnat Note I used server 10.100.93.6 for this. Here already was laravel. I unistalled it and clear everything regarding the laravel.

### Step 0. Clearing the server

systemctl list-units --type=service | egrep -i 'php|nginx|apache|supervisor|redis' || true  *Что из сервисов запущено*
dpkg -l | egrep -i 'php|nginx|apache2|composer|supervisor|redis' || true *Какие пакеты стоят*
sudo find / -xdev -type f -name artisan 2>/dev/null *Где лежат проекты Laravel (ищем файл artisan)*
ls -la /etc/apache2/sites-available/ 2>/dev/null *смотрим web config*

systemctl stop php*-fpm apache2 redis-server
systemctl disable php*-fpm apache2 redis-server
apt purge -y 'php*'
apt purge -y composer
apt purge  libonig5 libzip4t64 ??
rm -f /usr/local/bin/composer
ll /usr/local/bin/composer
sudo apt purge -y apache2 apache2-utils apache2-bin apache2-data || true
sudo apt purge -y 'redis*' || true
sudo apt purge -y mysql-client mariadb-client || true
sudo apt autoremove -y
sudo apt autoclean -y
sudo bash -c 'for f in $(find / -xdev -type f -name artisan 2>/dev/null); do d=$(dirname "$f"); echo "RM $d"; rm -rf "$d"; done'
sudo rm -rf /var/www/*
sudo rm -rf /srv/www/* 2>/dev/null || true
whereis nginx
sudo rm -rf /etc/php /var/lib/php /var/log/php* /var/run/php
`sudo bash -c 'for u in /home/*; do rm -rf "$u/.composer"; done'`
sudo rm -rf /root/.composer
sudo find /var/www /srv/www -maxdepth 3 -type d \( -name node_modules -o -name vendor \) -prune -exec rm -rf {} + 2>/dev/null || true
dpkg -l | egrep -i 'php|nginx|apache2|composer|supervisor|redis' || echo "Остатков пакетов не видно"
systemctl list-units --type=service | egrep -i 'php|nginx|apache|supervisor|redis' || echo "Сервисов не видно"
ls -la /var/www

*Snapshot 8/14/2025 11:02 "Clean versio of server without Laravel and Depencies" = Done*

### Step 1: Dependecies Laravel

#### PHP and Modules

sudo apt install php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-mysql php8.4-intl unzip curl git -y \
&& echo -e "\nInstalled Successfully:\n" && dpkg -l | grep -E 'php|unzip|curl|git' \
|| echo -e "\nIssues with installation" 
php -v
apt install -y composer
php -v
composer --version

#### Clone project - compose and config

mkdir -p /var/www/app02
chown -R $USER:$USER /var/www/app02
cd /var/www/app02/
git clone https://github.com/guillaumebriday/laravel-blog.git .
cp .env.example .env
export COMPOSER_ALLOW_SUPERUSER=1
composer install --no-interaction --prefer-dist

#### .env keygen migration

php artisan key:generate
nano /var/www/app02/.env
*add this*

```
APP_NAME=Laravel
APP_ENV=production
APP_KEY=base64:a8+gy85RIOpP9r3CLYPUT+pR5qgGRVLIxgrrpvaNW/0=
APP_DEBUG=false
APP_URL=http://localhost
LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=10.100.93.8
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel_user_app02
DB_PASSWORD=1323
```

php artisan storage:link
php artisan migrate:fresh

#### Preparing front (Node/Vite)

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt update
apt install -y nodejs
node -v
npm -v
cd /var/www/app02
sudo -u www-data npm install
sudo -u www-data npm run build

#### Vhost configuring

a2enmod php8.4
a2enmod rewrite headers env
systemctl restart apache2
nano /etc/apache2/sites-available/app02.conf

```
<VirtualHost *:80>
    ServerName 10.100.93.6
    DocumentRoot /var/www/app02/public

    <Directory /var/www/app02/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/app02_error.log
    CustomLog ${APACHE_LOG_DIR}/app02_access.log combined

    # Пробрасываем Authorization для некоторых middleware
    SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0
</VirtualHost>
```

a2dissite 000-default.conf
a2ensite app02.conf
sudo chown -R www-data:www-data storage bootstrap/cache
sudo find storage bootstrap/cache -type d -exec chmod 2775 {} \;
sudo find storage bootstrap/cache -type f -exec chmod 0664 {} \;
systemctl reload apache2

## Before Start

cd /var/www/app02

```
\ этот фрагмент даже лишний \
php artisan tinker
> PrepareNewsletterSubscriptionEmail::dispatch();
> q
```

php artisan cache:table
php artisan migrate:fresh --seed *or php artisan migrate*