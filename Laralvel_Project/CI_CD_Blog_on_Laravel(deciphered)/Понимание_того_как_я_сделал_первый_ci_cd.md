# В случае что нужно рестарнауть Docker (docker stop - rm - run)

cd /opt/ci-cd_laravel
git checkout develop
echo "# Restart test container" >> README.md
git add README.md
git commit -m "Trigger restart of test container"
git push origin develop

## Шаг 1: Понимание что мы делаем

```
Сейчас у вас работает сайт через Docker Compose с несколькими контейнерами (nginx + php + mysql + node). Мы создадим один большой контейнер, который будет содержать всё необходимое для работы сайта. Это называется "production-ready образ".
Зачем это нужно?
Проще развертывать на любом сервере
Один контейнер вместо нескольких
CI/CD может собрать этот контейнер и отправить куда угодно
```

```
Dockerfile.prod - это рецепт для сборки одного большого контейнера
nginx.conf - настройки веб-сервера внутри контейнера
supervisord.conf - программа которая следит чтобы nginx и php работали одновременно
start.sh - скрипт который запускается при старте контейнера
```

## Шаг 2: Создаём файлы для production-образ

### 2.1 Dockerfile.prod                                     (explained)

## Шаг 3: Создаём папку для конфигурационных файлов

### 3.1 docker/nginx.conf                                     (explained)

### 3.2 docker/supervisord.conf #конфигурация supervisor     (explained)

`В Docker-контейнере может работать только один главный процесс, но нам нужно nginx + php-fpm одновременно. Supervisor следит за обоими процессами и перезапускает их при падении.`

### 3.3 docker/start.sh         #стартовый скрипт            (explained)

1. Создаёт .env файл с настройками для production
2. Создаёт SQLite базу данных  
3. Настраивает права доступа к папкам
4. Генерирует ключ приложения Laravel
5. Запускает миграции и сиды (создаёт demo пользователя)
6. Кеширует конфигурацию для скорости
7. Запускает supervisor (nginx + php-fpm)

--------------------------

Ручной Тест:
Тестируем сборку production-образа, проверим что наш Dockerfile.prod работает правильно.
docker build -f Dockerfile.prod -t laravel-blog-prod:test .
После проверки что всё это работает ...

--------------------------

## Шаг 3: Создаём .gitlab-ci.yml для CI/CD                   (explained)

### 3.1 Включаем Container Registry в GitLab

### 3.2 Коммитим изменения и проверяем CI/CD

```
Что происходит:
GitLab получит ваш код
Запустится пайплайн автоматически
Этап build соберёт Docker образ
Этап test проверит что всё работает
Этап deploy будет ждать когда вы его запустите вручную
```