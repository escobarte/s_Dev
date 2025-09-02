# Laravel CI/CD Recap (Extended highlights)
Прежде чем начать делать CI CD проекта, его сначала в ручную нужно собрать, проверить что работает.
Какие этапы были у меня:
1. Shell deploy проекта. То есть весь проект был развёрнут в ручную.
2. Я сделал Shell Deploy использую Playbook. Не уверен что это правильный был подход. 
3. Локально сделал Docker Compose Laravel. То есть все сервисы были запущены в контейнерах, и сам проект остался на сервере (Скажем Test-Deploy)
4. CI/CD. Что это значит? Пунтк 3, сайт на Laravel был развёрнут. Я его запёк(Build) в один Dockerfile, со всеми его зависимостями окружения (nginx, php+fpm, sql, nodejs). После билда, контейнер был использован для дальнейшего развёртывания, на Deploy сервер для Теста. И уже финальная версия на Prod Server. 
5. Как работает пункт 4. Во первых проект нужно загрузить локально, или на нужный для сборки сервак.
Данную репозиторию (docker remote) с нужным Git-Lab. Установать Runners или использовать Git-Lab-овские.
Вот у тебя есть основаная ветка (master). 
5.1 Создаешь новую ветку на которой делаешь билд. Пушишь в Git и собираешь артефакт.
5.2 Создаешь ветку для Use Build + Deploy. Мерджишь с веткой от билда, удаляешь первую ветку для чистоты. Push и у тебя Use Build и Deploy на Dev среду для тестов и тд. Если всё ОК и выкатываем в Prod, делаешь merge c master ветвь и делашь Deploy на Prod Server.  

----------------------
Сейчас у вас работает сайт через Docker Compose с несколькими контейнерами (nginx + php + mysql + node). Мы создадим один большой контейнер, который будет содержать всё необходимое для работы сайта. Это называется "production-ready образ".
Зачем это нужно?

Проще развертывать на любом сервере
Один контейнер вместо нескольких
CI/CD может собрать этот контейнер и отправить куда угодно
-----------------------
Объяснение что мы сделали:

Dockerfile.prod - это рецепт для сборки одного большого контейнера
nginx.conf - настройки веб-сервера внутри контейнера
supervisord.conf - программа которая следит чтобы nginx и php работали одновременно
start.sh - скрипт который запускается при старте контейнера
---------------------------
Собираем образ
docker build -f Dockerfile.prod -t laravel-blog-prod:test .

Docker читает наш Dockerfile.prod
Собирает фронтенд (JavaScript/CSS)
Устанавливает PHP зависимости
Создаёт один готовый образ
-----------------------------

Создаём .gitlab-ci.yml для CI/CD
-----------------------------
 Включаем Container Registry в GitLab
Зайдите в ваш проект в GitLab:

Идите в Settings → General
Найдите секцию Visibility, project features, permissions
Убедитесь что Container registry включён
------------------------

Что происходит дальше:

GitLab получит ваш код
Запустится пайплайн автоматически
Этап build соберёт Docker образ
Этап test проверит что всё работает
Этап deploy будет ждать когда вы его запустите вручную
---------------------------

`Code → GitLab → Build Docker Image → Push to Registry → Deploy Image`

# Основные этапы в новом pipeline
### Build Stage:
Сборка Docker образа с приложением
Тестирование образа
### Push Stage:
Загрузка образа в Docker Registry (GitLab Container Registry)
Тегирование версий
### Deploy Stage:
Скачивание образа на целевой сервер
Запуск контейнера

#### {Заметки}
production-ready подход с оптимизированным образом
Преимущества production образа:
✅ Один самодостаточный контейнер
✅ Меньший размер (только production зависимости)
✅ Встроенный веб-сервер
✅ Готов для любой среды развертывания

============================================================
Steps
============================================================
1. Устанавливаем Runner и Настраиваем
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt install gitlab-runner
sudo systemctl status gitlab-runner
gitlab-runner --version
sudo gitlab-runner register
systemctl start gitlab-runner
systemctl enable gitlab-runner
gitlab-runner list
gitlab-runner verify
sudo usermod -aG sudo gitlab-runner                        [получает права для выполнения команд с sudo без ввода пароля, что необходимо для автоматизации процессов в GitLab CI/CD.]
sudo -u gitlab-runner whoami
sudo -u gitlab-runner bash -c 'cd /home && ls -la'
```
2. Добавляем gitlab-runner в группу docker
```
sudo getent group docker
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner
sudo getent group docker | grep gitlab-runner
*/ or
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner
sudo getent group docker | grep gitlab-runner
sudo -u gitlab-runner docker ps
```
3. Включаем Container Registry
```
Идите в ваш проект → Settings → General
Разверните Visibility, project features, permissions
Убедитесь что Container registry включён
```
4. Делае PUSH, пример будет на разных ветках.
```
git checkout -b feature/add-new-functionality
*/ допустим были сделаны изменения в коде \*
git add .
git commit -m "Add new functionality test"
git push origin feature/add-new-functionality
//
git checkout master
git checkout -b develop-test-1
git push origin develop-test-1
git merge feature/add-new-functionality
git push origin develop-test-1
## удаляем ненужное
git branch -d feature/add-new-functionality
git push origin --delete feature/add-new-functionality
//
git checkout master
git pull origin master
git merge develop-test-1
git push origin master
git branch -d develop-test-1
git push origin --delete develop-test-1

*/ ещё пример с коментарием при мердже\*
git merge --no-ff develop-test-1 -m "merged with master"

```
