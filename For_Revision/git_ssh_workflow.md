## 🧬 Git: Работа с репозиторием и настройка SSH-доступа к GitHub

---

### 📁 Переход в директорию проекта

```bash
cd /mnt/d/mcruzen
```

---

### 🧠 Tips and Tricks

```bash
git log --oneline --graph --decorate  # История в виде дерева
ls -a                                 # Показать скрытые файлы (.git и др.)
cat .git/config                       # Проверить конфигурацию текущего репозитория
git branch -M main                    # Переименовать ветку в main
```

---

### 🛠️ Базовый рабочий цикл Git

```bash
# Внесли изменения
git add .

# Коммит с сообщением
git commit -m "Опишите, что вы сделали"

# Отправка на удалённый репозиторий
git push

# Проверка состояния
git status
```

---

## 🛡️ SSH-доступ к GitHub

---

### 🧪 ШАГ 1: Проверка наличия SSH-ключей

```bash
cd ~/.ssh/
ls -l
```

- Если есть `id_rsa` и `id_rsa.pub`, переходи к **ШАГУ 3**.

---

### 🔐 ШАГ 2: Генерация новой пары ключей

```bash
ssh-keygen -t rsa -b 4096 -C "ваш_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

---

### 📋 ШАГ 3: Добавление ключа на GitHub

```bash
cat ~/.ssh/id_rsa.pub
```

- Перейди на [https://github.com](https://github.com)
- Настройки → **SSH and GPG keys** → **New SSH key**
- Назови ключ и вставь скопированный `.pub` файл

---

### 🔗 ШАГ 4: Настройка SSH-URL в репозитории

```bash
# Перейди в директорию проекта
cd /mnt/c/Users/ВашеИмяПользователя/Documents/МойПроект

# Удали старый origin
git remote remove origin

# Добавь новый origin через SSH
git remote add origin git@github.com:escobarte/stisc_devops.git

# Проверь
git remote -v
```

---

### 🧪 ШАГ 5: Проверка SSH-подключения

```bash
ssh -T git@github.com
# Должно появиться: "Hi <ваш_логин>! You've successfully authenticated..."
```
