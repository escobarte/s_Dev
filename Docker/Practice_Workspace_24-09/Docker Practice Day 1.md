**docker build -t image-for-build:v2.0 .**
**docker build -t image-for-build:v2.0 /path/to/folder**

*
`-t` = tag (тег/метка)
`image-for-build` = имя образа
`:v2.0` = верися(тег)
`.` = искать докерайл файл в текущей папке
`/path/to/folder` = искать докерфайл в /path/to/folder

```
Dcoker, собери образ из Dockerfile в текущей папке, назави его "image-for-build" с версией "2.0"
```

## Запуск Контейнер

docker run -d -p 9090:80 --name started-container-1 image-for-build:v2.0
`-d` = detached (в фоне чтобы не занимал терминал)
`-p 9090:80` = порт 9090 с наружи : порт 80 внутри
`--name started-container-1` = дать имя контейнеру "started-container-1"
`image-for-build:v2.0` = запустить образ "image-for-build:v2.0"

## Запуск контейнера с переменным окружением

`-e` = задать переменну окружения
`\` = перенос строки для читаемости

.Dockerfile

```bash
#Выбираю базовай образ
FROM alpine:3.14                                                                                                                                                                                                                                                                                                                                                                
#Устанавливаю MySql Client                                                                                                                                                              
RUN apk add --no-cache mysql-client                                                                                                                                                                                                                                                                                                                                             
#Задаём команду по умолчанию                                                                                                                                                            
ENTRYPOINT ["mysql"]
```

`RUN` = Выполнить команду при сборке
`apk` = apt
`add` = установить пакет
`--no-cache` = не сохранять кэг после установки
`mysql-client` = программу MySql
`ENTRYPOINT` = жестко заданная команда

.Dockerfile

```bash
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

`CMD` = команда по умолчанию при запуске
`["nginx", ` = запустить веб-сервер
`"-g", "daemon off;"]` = не уходить в фон, остаться активным

# docker compose down -v

# docker image prune -aw

Основные команды

```shortcode
FROM - базовый образ
RUN - выполнить команду при сборке
COPY - копировать файлы в контейнер
WORKDIR - установить рабочую директорию
EXPOSE - указать порт
CMD - команда по умолчанию при запуске
ENV - переменные окружения
```