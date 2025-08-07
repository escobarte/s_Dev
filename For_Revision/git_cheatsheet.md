# 🧠 Git Шпаргалка: Базовые команды

---

## 📍 Статус и ориентация

```bash
git status                          # Что изменено, какие файлы не закоммичены
git branch                          # Показать локальные ветки
git branch -a                       # Все ветки (локальные + удалённые)
git log --oneline                   # Краткий лог
git log --oneline --graph --all     # Ветки, история, слияния
git reflog                          # История всех движений HEAD (в т.ч. потерянных коммитов)
```

---

## ✅ Работа с изменениями

```bash
git add .                           # Добавить все изменения
git add file.txt                    # Добавить конкретный файл

git commit -m "Сообщение"           # Создать коммит
git push                            # Отправить в удалённый репозиторий
git pull                            # Получить и слить изменения
git fetch                           # Только забрать (без слияния)
```

---

## 🌿 Работа с ветками

```bash
git checkout main                   # Переключиться на ветку main
git checkout -b feature1            # Создать и перейти в новую ветку

git merge other-branch              # Слить другую ветку в текущую

git remote -v                       # Проверить удалённый репозиторий
git remote add origin git@...      # Добавить удалённый репозиторий
```

---

## 🧯 Восстановление и откат

```bash
git reset --hard <commit>          # Жёсткий откат до коммита
git checkout <commit>              # Посмотреть старый коммит
git checkout -b restore <commit>   # Создать ветку из старого состояния

git log HEAD..origin/master --oneline  # Что у origin, чего нет у тебя
```

---

## 🔒 Работа с SSH

```bash
ssh-keygen -t rsa -b 4096 -C "email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub               # Копируешь на GitHub
```
