_Отлично, берём готовый репозиторий guillaumebriday/laravel-blog (активный open-source блог на Laravel 11, с сидером демо-юзера и понятной установкой). Это хороший баланс «готово из коробки» и актуальности под PHP 8.3_

## How to clean old Laravel & BackUp
*cd /var/www/(name_of_project)*

cd /var/www/app02
sudo chown -R www-data:www-data /var/www/app02

# 1) Бэкап .env (если есть)
cp -a .env /root/app02.env.bak_$(date +%F_%H%M) 2>/dev/null || true

# 2) Архив текущего кода (исключим vendor/storage чтобы не раздулось)
tar -czf /root/app02_backup_$(date +%F_%H%M).tgz \
  --exclude=vendor --exclude=storage .

ls -lh /root/app02_backup_*.tgz | tail -n1

# 3) Очистка директории проекта
rm -rf ./* ./.git
rm -rf ./* ./.*
ls -la

*Copy in-to the same folder*
cd /var/www/app02
git clone https://github.com/amirsahra/dornica.git .
chown -R www-data:www-data .
ls -la *check if the owner is www-data*
sudo -u www-data composer install --no-interaction --prefer-dist --optimize-autoloader
*Мне всплыла ошибка, установил ещё зависимости*
sudo apt-get install php-gd
composer update
sudo -u www-data composer install --no-interaction --prefer-dist --optimize-autoloader

# .env
cp .env.example .env
chown -R www-data:www-data .env
nano .env
*copy setting to db connection from other personal examples or took it here*
**Don't forgent to change variables for correct**
```
DB_CONNECTION=mysql
DB_HOST=10.100.93.8
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel_user_app01
DB_PASSWORD=1323
```

# Generate Key
sudo -u www-data php artisan key:generate
grep ^APP_KEY .env

php artisan migrate:fresh
php artisan db:seed (seed fake data)

# Ошибка - на сайте не прогружаются картинки, не правельный путь оказался
*чтобы решить этот вопрос, я сделал inspect elemtn, и нашёл путь по которому сайт пытался загрузить картинку, сделал поиск по серверу где лежит на самом делел картинка, и создал симлинк*
```
find /var/www/app02 -type f -name "post-22.jpg"
rm -rf public/images
ln -s site/images public/images
```

sudo -u www-data php artisan storage:link
sudo chown -R www-data:www-data /var/www/app02/storage /var/www/app02/bootstrap/cache
sudo -u www-data php artisan optimize:clear
nano .env *add this*
`CACHE_STORE=file`
sudo -u www-data php artisan cache:table
sudo -u www-data php artisan migrate
sudo -u www-data php artisan optimize:clear


## В Случае проблемой с "Vite" frontend на manifest.json
# установка Node.js и npm (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt update
apt install -y nodejs
node -v
npm -v
sudo -u www-data npm install
sudo -u www-data npm run build


