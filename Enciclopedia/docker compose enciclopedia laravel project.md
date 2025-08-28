#### sudo chown -R "$SUDO_USER:$SUDO_USER" /opt/laravel-blog
```chown # сменить владельца / группу
$SUDO_USER:$SUDO_USER #установить владельца:группу равным значению переменной окружения $SUDO_USER
echo "$USER"        # ваше имя пользователя
echo "$SUDO_USER"   # кто вызвал sudo
id -un; id -gn      # имя пользователя и его основная группа
ls -ld /opt/laravel-blog  # посмотреть текущего владельца/группу
```
grep -nE 'root|try_files|fastcgi_pass' default.conf
```
grep — ищет строки по шаблону.
-n — показывает номер строки.
-E — включает расширенные регулярные выражения (то же, что устаревший egrep).
```

К примеру у меня такой случай что сначала билд делается потом поднимаются докеры, так сначала.
И я сделал ошибку, чтобы было всё хорошо нужно было 

`docker compose build php --no-cache`

`docker compose up -d --force-recreate web php`

`docker exec -t <container> bash`

`docker compose logs --no-color -n 50 <container_name>`

`
docker compose up -d --force-recreate web
docker compose exec web sh -lc 'nginx -t'
`

`ss -tulnp |grep '8080'`

`cp -r src src_bak_2`


#### docker compose exec php sh -lc 'cd /var/www/html && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-interaction --prefer-dist'

```
docker compose exec php — выполнить команду в уже запущенном контейнере сервиса php.

sh -lc '...' — запустить shell;
-c = выполнить строку; -l = как «login shell» (подтянет профиль окружения). Нужен, чтобы сработали cd, && и временная переменная.

cd /var/www/html && ... — перейти в папку проекта (убедись, что путь верный для твоего контейнера).

COMPOSER_ALLOW_SUPERUSER=1 — временно разрешить Composer работать от root (часто внутри контейнера процесс — root).

composer install — установить зависимости из composer.lock (или composer.json, если lock отсутствует).

--no-interaction — без вопросов (нужно для CI/скриптов).

--prefer-dist — тянуть готовые архивы (быстрее, чем git-clone источников).
```



#### Laravel устроены database seeders — «засеватели» БД:
```
Что это
Классы, которые заполняют базу данными: справочники (роли, страны), стартовые записи, демо-данные для разработки и тестов. В отличие от миграций (меняют схему), сидеры добавляют/обновляют содержимое.
Коротко: Seeder = класс, который программно заполняет БД данными. Создаёшь → описываешь run() → подключаешь в DatabaseSeeder → запускаешь php artisan db:seed.
```

#### healthcheck:
####	test: ["CMD", "mysqladmin", "ping", "-h", "127.0.0.1", "-proot"]
```
Что происходит:
Docker периодически запускает команду без шелла (exec-форма).
Команда mysqladmin ping -h 127.0.0.1 -proot пытается подключиться к mysqld по TCP к самому контейнеру (127.0.0.1 внутри контейнера) паролем root (пользователь по умолчанию — root).
Если сервер отвечает «alive» (код выхода 0) → статус контейнера healthy; иначе → unhealthy.
```

#### `sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env`
```
sed — потоковый редактор.
-i — правка файла на месте (in-place).
s/…/…/ — операция замены (substitute).
^DB_CONNECTION= — начало строки + точное имя ключа.
Не тронет закомментированные #DB_CONNECTION=… и другие ключи.
.* — всё, что стоит после =.
DB_CONNECTION=mysql — чем заменить.
Итого: в .env строка вида
DB_CONNECTION=что-угодно → станет DB_CONNECTION=mysql.
```

##### grep -n 'some_text' .env
```
grep - ищет строку по шаблону в файлу .env
-n - показывает номер строки
```

#### docker compose 
```
docker compose exec web sh -lc 'grep -n "root /var/www/html/public" /etc/nginx/conf.d/default.conf || echo NO_ROOT_LINE'
docker compose exec web sh -lc 'ls -l /var/www/html/public/index.php || echo NO_INDEX_WEB'

docker compose exec php sh -lc 'ls -l /var/www/html/public/index.php || echo NO_INDEX_PHP'
curl -sI http://127.0.0.1:8080/ | head -n1
curl -s http://127.0.0.1:8080/index.php | grep -i "php version" -m1 || true
docker compose up -d --force-recreate web
docker compose logs --no-color -n 50 web
docker compose up -d --force-recreate web
docker compose exec web sh -lc 'nginx -t'
```