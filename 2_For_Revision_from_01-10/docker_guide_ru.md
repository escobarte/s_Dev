# 🐳 Docker: Человеко-Понятный Гид

> **От новичка до практика за одно занятие**

---

## 🎯 Что такое Docker простыми словами

**Docker** = способ упаковать программу со всем необходимым в один "контейнер"

**Зачем нужен:**
- Программа работает одинаково на любом компьютере
- Легко установить и удалить
- Изолирован от других программ

**Аналогия:** Docker как контейнер для перевозки грузов - что положил, то и приехало, без повреждений

---

## 📦 Основные понятия

### Образ (Image)
**Что это:** Шаблон/чертеж для создания контейнера  
**Пример:** Ubuntu, Nginx, PostgreSQL

### Контейнер (Container)
**Что это:** Запущенная копия образа  
**Пример:** Работающий веб-сервер

### Dockerfile
**Что это:** Рецепт для создания образа  
**Формат:** Текстовый файл с инструкциями

### Docker Compose
**Что это:** Инструмент для запуска нескольких контейнеров сразу  
**Формат:** YAML файл с описанием всех сервисов

---

## 🔨 Dockerfile: 7 главных команд

### 1. FROM - Основа
```dockerfile
FROM nginx:alpine
```
**Простыми словами:** "Возьми чистую кастрюлю Nginx"  
**Зачем:** Нужна база для старта

### 2. WORKDIR - Рабочая папка
```dockerfile
WORKDIR /app
```
**Простыми словами:** "Работай в этой папке"  
**Зачем:** Организация файлов

### 3. COPY - Копирование
```dockerfile
COPY index.html /usr/share/nginx/html/
```
**Простыми словами:** "Перенеси мой файл в контейнер"  
**Формат:** `COPY откуда куда`

### 4. RUN - Выполнить при сборке
```dockerfile
RUN apt-get install python3
```
**Простыми словами:** "Установи это СЕЙЧАС (один раз)"  
**Когда:** Установка пакетов, настройка

### 5. EXPOSE - Порт
```dockerfile
EXPOSE 80
```
**Простыми словами:** "Оставь дверь 80 открытой"  
**ВАЖНО:** Это только документация!

### 6. CMD - Команда запуска
```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```
**Простыми словами:** "Когда запустишь - сделай это"  
**Когда:** Каждый раз при старте контейнера

### 7. ENV - Переменные
```dockerfile
ENV PORT=3000
```
**Простыми словами:** "Сохрани эту настройку"  
**Использование:** Конфигурация приложения

---

## 🚀 Docker: Основные команды

### Сборка образа
```bash
docker build -t myapp:v1.0 .
```
**Что делает:** Создает образ из Dockerfile  
**Параметры:**
- `-t myapp:v1.0` = имя и версия
- `.` = текущая папка

### Запуск контейнера
```bash
docker run -d -p 8080:80 --name web myapp
```
**Что делает:** Запускает контейнер из образа  
**Параметры:**
- `-d` = в фоне (не блокирует терминал)
- `-p 8080:80` = порт снаружи:внутри
- `--name web` = имя контейнера

### Проверка статуса
```bash
docker ps              # Запущенные
docker ps -a           # Все контейнеры
docker images          # Список образов
```

### Просмотр логов
```bash
docker logs web        # Логи контейнера
docker logs -f web     # Следить в реальном времени
```

### Остановка и удаление
```bash
docker stop web        # Остановить
docker rm web          # Удалить контейнер
docker rmi myapp       # Удалить образ
```

---

## 🎼 Docker Compose: Управление несколькими сервисами

### Зачем нужен
**Проблема:** Вручную запускать 3-5 контейнеров долго  
**Решение:** Один файл, одна команда - все работает

### Базовая структура
```yaml
services:
  web:
    build: .
    ports:
      - "9091:8080"
    depends_on:
      - database

  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - data:/var/lib/postgresql/data

volumes:
  data: {}
```

### Ключевые блоки

#### services:
**Что это:** Список всех контейнеров  
**Пример:** web, database, redis

#### ports:
```yaml
ports:
  - "9091:8080"
```
**Формат:** `"внешний:внутренний"`  
**Пример:** localhost:9091 → контейнер:8080

#### environment:
```yaml
environment:
  DB_PASSWORD: secret
```
**Что это:** Настройки для контейнера

#### volumes:
```yaml
volumes:
  - mydata:/var/lib/postgresql/data
```
**Зачем:** Сохранить данные между перезапусками  
**Без volumes:** Данные исчезнут при остановке

#### depends_on:
```yaml
depends_on:
  - database
```
**Зачем:** База запустится раньше веб-сервера

---

## 🎮 Команды Docker Compose

```bash
docker-compose up -d       # Запустить все
docker-compose down        # Остановить все
docker-compose down -v     # Остановить + удалить данные
docker-compose ps          # Статус
docker-compose logs        # Логи всех сервисов
docker-compose logs web    # Логи одного сервиса
docker-compose restart     # Перезапустить
```

---

## 🏗️ Практический пример: Сайт + База + Админка

### Что создаем
- **Web:** Nginx сайт (порт 9091)
- **Database:** PostgreSQL
- **Adminer:** Веб-панель для БД (порт 9092)

### Структура папки
```
project/
├── Dockerfile
├── docker-compose.yml
└── index.html
```

### Dockerfile
```dockerfile
FROM nginx:alpine

# Настройка порта 8080
RUN echo 'server { listen 8080; root /usr/share/nginx/html; }' \
    > /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

### docker-compose.yml
```yaml
services:
  web:
    build: .
    ports:
      - "9091:8080"
    depends_on:
      - database

  database:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 30s

  adminer:
    image: adminer:latest
    ports:
      - "9092:8080"
    depends_on:
      - database

volumes:
  postgres_data: {}
```

### Запуск проекта
```bash
docker-compose up -d
```

### Проверка
- Сайт: http://localhost:9091
- Админка БД: http://localhost:9092
  - Сервер: `database`
  - Пользователь: `postgres`
  - Пароль: `password`

---

## 🔥 Критические моменты

### 1. Порты: внешний:внутренний
```yaml
ports:
  - "9091:8080"
```
**Запомни:** Слева (9091) = с компьютера, Справа (8080) = в контейнере

### 2. Volumes обязательны для БД
```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```
**Без этого:** Все данные исчезнут при остановке

### 3. depends_on - порядок важен
```yaml
depends_on:
  - database
```
**Иначе:** Веб-сервер запустится раньше БД и упадет

### 4. Сеть работает по именам
**В compose:** Сервисы находят друг друга по имени  
**Пример:** `database:5432` вместо `localhost:5432`

### 5. Healthcheck для надежности
```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "postgres"]
```
**Зачем:** Проверяет, что сервис действительно готов

---

## 🚨 Типичные ошибки и решения

### Ошибка: "volumes must be a mapping"
**Причина:** Неправильный синтаксис  
**Решение:**
```yaml
# ❌ Неправильно
volumes:
  postgres_data:

# ✅ Правильно
volumes:
  postgres_data: {}
```

### Ошибка: "port is already allocated"
**Причина:** Порт занят другой программой  
**Решение:**
```bash
# Проверить что занимает порт
sudo lsof -i :9091

# Изменить порт в docker-compose.yml
ports:
  - "9093:8080"  # используй свободный порт
```

### Ошибка: "database exited with code 1"
**Причина:** Конфликт старых данных  
**Решение:**
```bash
docker-compose down -v     # Удалить volumes
docker-compose up -d       # Запустить заново
```

### Ошибка: "Cannot connect to database"
**Причина:** Неправильное имя хоста  
**Решение:**
```javascript
// ❌ Неправильно
host: 'localhost'

// ✅ Правильно (имя сервиса)
host: 'database'
```

---

## 📋 Чек-лист: Что должен знать каждый

### Минимум
- [ ] Что такое образ и контейнер
- [ ] Создать простой Dockerfile
- [ ] Собрать образ: `docker build`
- [ ] Запустить контейнер: `docker run`
- [ ] Пробросить порты: `-p 8080:80`

### Уверенный пользователь
- [ ] Писать docker-compose.yml
- [ ] Связывать несколько сервисов
- [ ] Использовать volumes
- [ ] Настраивать environment
- [ ] Читать и чинить ошибки

### Профессионал
- [ ] Оптимизировать размер образов
- [ ] Многоэтапная сборка (multi-stage)
- [ ] Настройка сетей
- [ ] Использовать secrets
- [ ] Интеграция с CI/CD

---

## 🎓 Главные выводы

### 1. Docker - это просто
Dockerfile = рецепт  
Образ = торт по рецепту  
Контейнер = кусок торта на тарелке

### 2. Docker Compose - для сложных проектов
Один файл → много сервисов → одна команда

### 3. Volumes = безопасность данных
БД без volume = потеря всех данных при перезапуске

### 4. Порты нужно понимать
`-p 9091:8080` = "Я стучусь в 9091, а попадаю в 8080"

### 5. Практика важнее теории
Запускай, ломай, чини - так быстрее научишься

---

## 🛠️ Шпаргалка команд

```bash
# === DOCKER ===
docker build -t app .           # Собрать
docker run -d -p 8080:80 app    # Запустить
docker ps                       # Что работает
docker logs app                 # Логи
docker stop app                 # Остановить
docker rm app                   # Удалить

# === DOCKER COMPOSE ===
docker-compose up -d            # Запустить все
docker-compose down             # Остановить все
docker-compose logs -f          # Следить за логами
docker-compose ps               # Статус
docker-compose restart          # Перезапустить

# === ОЧИСТКА ===
docker system prune             # Очистить неиспользуемое
docker volume prune             # Удалить volumes
docker-compose down -v          # Остановить + удалить volumes
```

---

## 📚 Куда двигаться дальше

### Следующий уровень
1. **Kubernetes** - оркестрация на продакшене
2. **CI/CD** - автоматический деплой
3. **Мониторинг** - Grafana, Prometheus
4. **Микросервисы** - архитектура приложений

### Полезные ресурсы
- [docs.docker.com](https://docs.docker.com) - официальная документация
- [hub.docker.com](https://hub.docker.com) - готовые образы
- [docker.com/compose](https://docs.docker.com/compose/) - Docker Compose docs

---

## 🎯 Последний совет

**Начни с малого:**
1. Запусти готовый образ: `docker run hello-world`
2. Создай простой Dockerfile
3. Собери свой первый образ
4. Попробуй docker-compose с 2-3 сервисами
5. Экспериментируй и не бойся ошибок!

**Помни:** Каждый эксперт когда-то был новичком. Практика делает мастера! 🚀

---

**Создано:** 01.10.2025  
**Версия:** 1.0  
**Лицензия:** Free to use

---

*Этот гид создан на основе реального практического занятия. Все примеры проверены и работают.*