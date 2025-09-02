Predisposition Tools:
1. Install Docker 
2. Install & Configure Gitlab-Runner

cd /opt/<Project_Name>
1. Создаём Dockerfile.prod
nano Dockerfile.prod
2. Директория для конфигурационных файлов
mkdir -p docker
2.1 Конфигурация Nginx для контейнера
nano docker/nginx.conf
2.2.Конфигурация Supervisor
nano docker/supervisord.conf
3. Стартовый скрипт
nano docker/start.sh
4. Создаём .gitlab-ci.yml
nano .gitlab-ci.yml
4.1 Проверяем что Container Registry активен

