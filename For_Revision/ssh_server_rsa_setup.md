## 🔐 Настройка SSH-доступа с сервера и через RSA-ключи

---

### 🖥️ Установка SSH-сервера на [SERVER]

```bash
sudo apt update
sudo apt install openssh-server -y

# Проверка и запуск службы
sudo systemctl status ssh
sudo systemctl enable ssh
sudo systemctl start ssh

# Получение IP
hostname -I
```

---

### 🔓 Открытие порта 22 в UFW (если используется)

```bash
sudo ufw status
sudo ufw allow ssh
sudo ufw reload
```

---

## 🗝️ SSH через RSA-ключи

### 1️⃣ Создание ключа на клиенте (например, WSL)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_scusnir -C "scusnir"
```

- Ключи создаются в `~/.ssh/`
  - Приватный: `id_rsa_scusnir`
  - Публичный: `id_rsa_scusnir.pub`

---

### 2️⃣ Добавление публичного ключа в FreeIPA

- Перейти в браузере на:
  
  ```
  https://dc1.gov.ipa/ipa/ui/#
  ```
- Найти пользователя: `scusnir`
- Вставить содержимое `id_rsa_scusnir.pub` в поле Public SSH Key
- Сохранить

---

### 3️⃣ Подключение к серверу через SSH (с WSL или другого клиента)

```bash
ssh -i ~/.ssh/id_rsa_scusnir scusnir@<server_IP>
```
