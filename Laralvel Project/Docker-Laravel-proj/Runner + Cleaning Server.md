# Cleaning Server from (old_laravel) + Runner
```
APP_DIR="/var/www/app03"   # ← корень твоего проекта Laravel
# Показать все конфиги, где встречается путь проекта
sudo grep -RIl "$APP_DIR" \
  /etc/nginx /etc/apache2 /etc/php/*/fpm/pool.d /etc/supervisor \
  /etc/systemd/system /etc/logrotate.d 2>/dev/null | sort -u

# Найти vhost’ы Apache, которые ссылаются на APP_DIR
sudo grep -RIl "$APP_DIR" /etc/apache2/sites-available 2>/dev/null | sort -u

# Для каждого найденного файла (например, app03.conf):
sudo a2dissite app03.conf          # ← отключить сайт
sudo rm -f /etc/apache2/sites-available/app03.conf   # ← удалить конфиг

# Проверить синтаксис и мягко перегрузить Apache
sudo apache2ctl configtest && sudo systemctl reload apache2

# Найти пул(ы) FPM, где упоминается APP_DIR
sudo grep -RIl "$APP_DIR" /etc/php/*/fpm/pool.d 2>/dev/null | sort -u

# Удалить найденные пул-файлы (пример):
sudo rm -f /etc/php/8.3/fpm/pool.d/app03.conf   # ← свой путь/версию подставь

# Перезапустить PHP-FPM (подставь действующий юнит, смотри через list-units)
systemctl list-units --type=service | grep fpm   # ← посмотреть имя сервиса
sudo systemctl restart php8.3-fpm                # ← перезапусти свой fpm

# Полностью удалить каталог проекта (код, .env, vendor, .git — всё уйдёт)
sudo rm -rf "$APP_DIR"

# Повторно проверить, остались ли ссылки на APP_DIR
sudo grep -RIl "$APP_DIR" \
  /etc/nginx /etc/apache2 /etc/php/*/fpm/pool.d /etc/supervisor \
  /etc/systemd/system /etc/logrotate.d 2>/dev/null || echo "Хвостов не найдено."

  # Найти юниты php-fpm и остановить (если есть)
systemctl list-units --type=service | awk '/php.*fpm/ {print $1}' | xargs -r -I{} sudo systemctl stop {}

# Если composer ставили из apt — удалить пакет
sudo apt-get -y purge composer || true

# Если composer лежит как файл в /usr/local/bin — удалить бинарник
sudo rm -f /usr/local/bin/composer /usr/bin/composer 2>/dev/null || true

# Почистить кэши composer (не критично, но освобождает место)
sudo rm -rf /root/.composer /home/*/.composer 2>/dev/null || true

# Реальное удаление всех установленных PHP-пакетов
dpkg -l | awk '/^ii\s+php/ {print $2}' | xargs -r sudo apt-get -y purge

# На всякий случай убрать модуль Apache mod_php, если был
sudo apt-get -y purge 'libapache2-mod-php*' || true

# Удалить остаточные конфиги PHP (если остались директории)
sudo rm -rf /etc/php 2>/dev/null || true

# Удалить репозиторий PPA Ondřej (если он есть)
sudo add-apt-repository -y --remove ppa:ondrej/php || true

# Симуляция, чтобы увидеть последствия (кто будет затронут)
sudo apt-get -s purge git

# Реальное удаление git и сопутствующих пакетов (git, git-man)
sudo apt-get -y purge git git-man

# Удалить автоматически неиспользуемые зависимости
sudo apt-get -y autoremove

# Почистить локальный кэш пакетов
sudo apt-get -y autoclean
sudo apt-get -y clean

# Обновить индексы (особенно после удаления PPA)
sudo apt-get update
```
```
#### Проверка что всё удаленно 
# PHP
command -v php || echo "php не найден"
dpkg -l | awk '/^ii\s+php/ {print $2}' || echo "PHP-пакеты не найдены"

# Composer
command -v composer || echo "composer не найден"

# Git
command -v git || echo "git не найден"
dpkg -l | awk '/^ii\s+git($|\s)/ {print $2}' || echo "git не найден (пакетов нет)"
```



```
### Install **SHELL RUNNER** Runner
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
### Install **DOCKER** Runner



#### Runner NOPASSWD
```
Шаг 1. Дать gitlab-runner sudo без пароля
Выполни на сервере (как root):
# проверить под кем бежит раннер (обычно gitlab-runner)
systemctl cat gitlab-runner | sed -n '1,120p' | grep -i '^User=' || true
# выдать NOPASSWD
echo 'gitlab-runner ALL=(ALL) NOPASSWD:ALL' | tee /etc/sudoers.d/010-gitlab-runner-nopasswd
chmod 440 /etc/sudoers.d/010-gitlab-runner-nopasswd
# быстрый тест: не должен ничего спрашивать
sudo -u gitlab-runner -H bash -lc 'sudo -n true && echo OK || echo FAIL'
```
