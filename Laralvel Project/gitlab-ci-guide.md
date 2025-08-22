# Типовой поток

- Фича-ветки / MR → гоняем CI-проверки: phpunit, lint, build фронта.  
  Цель: не сломать main. Деплоя нет.

- master / main → после merge автодеплой на staging.  
  Цель: быстро увидеть результат в окружении, похожем на прод.

- Прод → вручную (manual) по релиз-тегу (v1.2.3) или кнопкой.  
  Цель: контроль и откат по тегу.

- Защита: protected branches/tags, секреты в CI variables (Masked/Protected).

---

## Мини-шаблон для твоего проекта

Вставь в начало `.gitlab-ci.yml`:

```yaml
# Создаём pipeline для push и MR
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'   # MR
    - if: '$CI_PIPELINE_SOURCE == "push"'                  # любой пуш (ветки)
```

Дальше разделим правила:

```yaml
# Правила для CI (тесты/сборка) — на любом пуше и в MR
.ci_rules: &ci_rules
  - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  - if: '$CI_PIPELINE_SOURCE == "push"'

# Деплой на staging — только пуш в master
.deploy_staging_rules: &deploy_staging_rules
  - if: '$CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH == "master"'

# Деплой на prod — только релиз-теги, запуск вручную
.deploy_prod_rules: &deploy_prod_rules
  - if: '$CI_COMMIT_TAG =~ /^v?\d+\.\d+\.\d+$/'  # v1.2.3 или 1.2.3
    when: manual
```

Применяем к твоим job’ам (покажу на первых и двух деплоях; остальные добавь аналогично):

```yaml
stages: [bootstrap, setup, configure, assets, web, finalize]

install-dependencies:
  stage: bootstrap
  tags: ["n1-laravel"]
  rules: *ci_rules
  # ...

clone-and-configure:
  stage: setup
  tags: ["n1-laravel"]
  rules: *ci_rules
  # ...

prepare-frontend:
  stage: assets
  tags: ["n1-laravel"]
  rules:
    - changes: ["package.json", "package-lock.json", "resources/**"]  # собирать только если фронт менялся
    - when: never
  # ...

# Staging deploy (твой текущий деплой)
before-start:
  stage: finalize
  tags: ["n1-laravel"]
  rules: *deploy_staging_rules
  script:
    - cd /var/www/app02
    - sudo -u www-data bash -lc 'cd "$DEPLOY_DIR"; php artisan cache:table || true'
    - sudo -u www-data bash -lc 'cd "$DEPLOY_DIR"; php artisan migrate:fresh --seed --force'
  environment:
    name: staging
  resource_group: app02-staging   # не пускать два деплоя параллельно

# Prod deploy (тот же скрипт или свой)
deploy-prod:
  stage: finalize
  tags: ["n1-laravel"]
  rules: *deploy_prod_rules
  script:
    - echo "Deploy to PROD…"; # твои шаги деплоя на прод
  environment:
    name: production
  resource_group: app02-prod
```

## Почему так удобно

- В ветках и MR у тебя только CI-проверки → быстрые и дешёвые.
- После merge в `master` — авто-staging.
- На прод — ручная кнопка по тегу → воспроизводимость и откаты.

## Ещё парочка практичных фишек

- `changes:` для тяжёлых джобов (сборка фронта, выкаты vhost) — запускай, только если затронуты соответствующие файлы.
- `resource_group` — не даст двум деплоям в одно окружение идти одновременно.
- Protected ветка `master` и protected tags — чтобы деплоили только разрешённые люди.
- Секреты (пароли БД, APP_KEY) — в Settings → CI/CD → Variables (Masked, Protected).
