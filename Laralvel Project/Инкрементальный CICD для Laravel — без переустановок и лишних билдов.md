# Инкрементальный CI/CD для Laravel — без переустановок и лишних билдов

Ниже — чёткая стратегия, как сделать так, чтобы при каждом пуше **не** переустанавливался весь стек и не пересобиралось всё подряд. Мы остаёмся на твоём shell‑runner’е и деплое по месту (`/var/www/app02`), но добавляем **условия запуска**, **кеши** и **ручные шаги** там, где нужно.

---

## Две модели деплоя (коротко)

1. **In‑place (как у тебя сейчас)** — обновляем тот же каталог. Плюсы: просто. Минусы: откат сложнее.
2. **Releases (Capistrano‑стиль)** — `/var/www/app02/releases/<ts>` + симлинк `current`. Плюсы: атомарный свитч и быстрый роллбек. Минусы: нужно чуть больше логики.

> В этом документе — готовый **In‑place** вариант. Если решишь перейти на **Releases**, добавлю шаблон.

---

## Принципы

* **Provisioning не трогать каждый раз**: всё, что ставит пакеты APT — либо руками один раз, либо через job с ручным запуском.
* **Сборка — только при нужных изменениях**: front билдим только если менялись `resources/**`, `package*.json`, `vite.config.*`.
* **Composer — только при смене зависимостей**: если **менялся `composer.lock`**.
* **Миграции — только при наличии новых миграций** (или вручную).
* **Веб‑сервер** — конфиг не трогать без причин (ручной job/changes по conf‑файлам).

---

## Глобальные настройки (по желанию)

```yaml
# 1) Авто‑отмена лишних пайплайнов — включи в Settings → CI/CD → General → Auto-cancel redundant pipelines

# 2) По умолчанию не гонять provisioning
workflow:
  rules:
    - when: always
```

---

## Базовая структура стадий

```yaml
stages: [precheck, bootstrap, setup, configure, assets, web, finalize]
```

---

## Precheck: проверка sudo NOPASSWD (быстро и явно)

```yaml
sudo-precheck:
  stage: precheck
  tags: ["YOUR_RUNNER_TAG"]
  script:
    - |
      if sudo -n true 2>/dev/null; then
        echo "OK: sudo NOPASSWD доступен"
      else
        echo "ERROR: добавь gitlab-runner в sudoers (NOPASSWD) и перезапусти"; exit 1
      fi
```

> Добавь `needs: ["sudo-precheck"]` ко всем джобам, где есть `sudo`.

---

## 1) Bootstrap (APT) — запуск вручную или по переменной

```yaml
install-dependencies:
  stage: bootstrap
  tags: ["YOUR_RUNNER_TAG"]
  needs: ["sudo-precheck"]
  rules:
    - if: '$RUN_BOOTSTRAP == "1"'  # можешь принудительно включить
      when: on_success
    - when: manual                  # по умолчанию ручной запуск
  script:
    - sudo -n apt-get update
    - sudo -n apt-get install -y php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-mysql php-intl unzip curl git composer
```

**Идея:** provisioning ты делаешь редко. Пусть job по умолчанию **не** стартует на каждый пуш.

---

## 2) Checkout/Sync — всегда, но быстро (без реклона)

```yaml
checkout-sync:
  stage: setup
  tags: ["YOUR_RUNNER_TAG"]
  script:
    - DEPLOY_DIR=/var/www/app02
    - APP_REPO_URL="https://github.com/guillaumebriday/laravel-blog.git"
    - sudo -n install -d -m 2775 -o gitlab-runner -g www-data "$DEPLOY_DIR"
    - git config --global --add safe.directory "$DEPLOY_DIR" || true
    - |
      if [ -d "$DEPLOY_DIR/.git" ]; then
        git -C "$DEPLOY_DIR" remote set-url origin "$APP_REPO_URL" || true
        git -C "$DEPLOY_DIR" fetch --depth=1 origin "$CI_COMMIT_BRANCH"
        git -C "$DEPLOY_DIR" checkout -f "$CI_COMMIT_BRANCH"
        git -C "$DEPLOY_DIR" reset --hard "$CI_COMMIT_SHA"
      else
        git clone --depth=1 --branch "$CI_COMMIT_BRANCH" "$APP_REPO_URL" "$DEPLOY_DIR"
      fi
```

> Это быстро: скачивается только нужный коммит, без повторного клона.

---

## 3) Composer — только при смене зависимостей

```yaml
composer-install:
  stage: configure
  tags: ["YOUR_RUNNER_TAG"]
  needs: ["checkout-sync"]
  rules:
    - changes:
        - composer.lock       # ← триггерим только если менялся lock
      when: on_success
    - when: never
  script:
    - cd /var/www/app02
    - export COMPOSER_ALLOW_SUPERUSER=1
    - composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader
```

> При остальных пушах job будет **пропущен**, и останутся предыдущие `vendor/`.

---

## 4) ENV/Key/Migrate — гибко по изменениям

```yaml
env-and-migrate:
  stage: configure
  tags: ["YOUR_RUNNER_TAG"]
  needs: ["checkout-sync"]
  rules:
    - changes:
        - database/migrations/**    # новые миграции
        - database/seeders/**       # сиды
        - config/**                 # настройка влияет на кеш/миграции
      when: on_success
    - when: manual                  # иначе вручную (например, prod)
  variables:
    MIGRATE_FRESH: "false"
  script:
    - cd /var/www/app02
    - '[ -f .env ] || cp .env.example .env'
    - KEY="$(php artisan key:generate --show | tail -n1 | tr -d '\r')"
    - sed -i "s|^APP_KEY=.*|APP_KEY=${KEY}|" .env || echo "APP_KEY=${KEY}" >> .env
    - php artisan storage:link || true
    - |
      if [ "$MIGRATE_FRESH" = "true" ]; then
        php artisan migrate:fresh --seed --force
      else
        php artisan migrate --seed --force
      fi
```

> Контролируешь миграции: **по изменениям** или **вручную**.

---

## 5) Front (Vite) — только при изменениях фронта

```yaml
prepare-frontend:
  stage: assets
  tags: ["YOUR_RUNNER_TAG"]
  needs: ["checkout-sync"]
  rules:
    - changes:
        - package.json
        - package-lock.json
        - vite.config.*
        - resources/**
      when: on_success
    - when: never
  script:
    - cd /var/www/app02
    - sudo -n chown -R www-data:www-data .
    - sudo -u www-data env HOME="$PWD" npm ci --no-audit --no-fund --cache "$PWD/.npm-cache"
    - sudo -u www-data env HOME="$PWD" npm run build
```

> Если фронт не менялся — job **пропустится**, и останется прежний `public/build`.

---

## 6) Apache/FPM конфиг — только при изменении конфига (или вручную)

```yaml
apache-vhost:
  stage: web
  tags: ["YOUR_RUNNER_TAG"]
  needs: ["checkout-sync"]
  rules:
    - changes:
        - ops/apache/app02.conf     # храни шаблон в репозитории
      when: on_success
    - when: manual
  script:
    - sudo -n cp ops/apache/app02.conf /etc/apache2/sites-available/app02.conf
    - sudo -n a2ensite app02.conf && sudo -n apache2ctl configtest && sudo -n systemctl reload apache2
```

> Держи vhost‑шаблон в репозитории. Тогда GitLab сам решит, когда job запускать.

---

## 7) Финальные задачи (очереди/тестовые диспатчи) — вручную или по изменениям job‑класса

```yaml
before-start:
  stage: finalize
  tags: ["YOUR_RUNNER_TAG"]
  needs: ["checkout-sync"]
  rules:
    - changes:
        - app/Jobs/PrepareNewsletterSubscriptionEmail.php
      when: on_success
    - when: manual
  script:
    - cd /var/www/app02
    - sudo -n install -d -m 2775 -o www-data -g www-data storage/logs
    - sudo -n chown -R www-data:www-data storage bootstrap/cache
    - sudo -u www-data php artisan tinker --execute='\App\Jobs\PrepareNewsletterSubscriptionEmail::dispatch();'
```

---

## Кеши (опционально, если runner не «по месту»)

На shell‑runner’е кеши менее критичны (файлы остаются на диске). Но если станет нужно:

```yaml
# Composer cache
cache:
  key:
    files: [composer.lock]
  paths:
    - vendor/
  policy: pull-push

# NPM cache
cache:
  key:
    files: [package-lock.json]
  paths:
    - node_modules/
  policy: pull-push
```

> На твоём стенде достаточно локального состояния + `npm ci`/`composer install` **только при изменениях**.

---

## Так как это будет работать «в жизни»

* Разработчик пушит изменение **только PHP‑кода** → сработает `checkout-sync` и (в зависимости от правил) `env-and-migrate` **если** менялись миграции/сиды; фронт/продвижение APT/Apache — **пропускаются**.
* Меняется зависимость (обновлён `composer.lock`) → запустится **только** `composer-install` (и зависящие шаги).
* Меняется фронт (`resources/**`, `package*.json`) → запустится **только** сборка фронта.
* Конфиг веб‑сервера — вручную или по изменению шаблона.
* Редкие «админские» вещи (APT) — вручную или по флажку `RUN_BOOTSTRAP=1`.

---

## Советы по откатам и безопасным миграциям

* Для **in‑place** отката держи теги релизов: `git tag prod-YYYYMMDDHHmm <commit>`; чтобы вернуть — `git reset --hard <tag>` + «обратные» миграции (если предусмотрены).
* Если миграции потенциально разрушительные — запускай job `env-and-migrate` **вручную** после проверки.
* При желании — переход на **releases** даст атомарный свитч и быстрый роллбек (добавлю шаблон по запросу).

---

## Мини‑чеклист

* [ ] `install-dependencies` — manual/по флажку.
* [ ] `composer-install` — **только** при изменении `composer.lock`.
* [ ] `prepare-frontend` — **только** при изменении фронта.
* [ ] `env-and-migrate` — по изменениям миграций/сидов (или вручную).
* [ ] `apache-vhost` — manual/по изменению шаблона.
* [ ] `before-start` — manual/по изменению соответствующего job‑класса.

Готово. С этим пайплайн будет выполнять **только то, что действительно нужно**, без переустановки и лишних билдов.
