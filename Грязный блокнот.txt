Решение 1: Volume для SQLite базы (простое)
Изменим способ запуска контейнера - добавим внешний volume для базы:
# Создаём именованный volume для базы
``docker volume create laravel-db``

# Запускаем контейнер с volume
```
docker run -d --name laravel-blog-test -p 8080:80 \
  -v laravel-db:/var/www/html/database \
  laravel-blog-prod:test
```
Что происходит:

База данных сохраняется в Docker volume
При удалении контейнера база остаётся
При новом запуске подключается та же база

```
docker build -f Dockerfile.prod -t laravel_blog:test4 .
docker run -d --name my-blog4 -p 8080:80 -v laravel-db:/var/www/hmlt/database laravel_blog:test4

```

