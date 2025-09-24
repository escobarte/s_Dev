# 🧾 Laravel Project Setup with LVM, Apache, and MySQL

## 1. Подготовка LVM
- Размечен диск `/dev/sdb`, создан раздел под LVM (`type 8e`).
- Создана PV, VG `vg_app2`, и LV `www` размером 5 ГБ.
- Раздел отформатирован в `ext4`, примонтирован в `/var/www`, добавлен в `/etc/fstab`.

**Ошибка:** первоначально Volume Group создана с опечаткой (`vp_app2`), переименована через `vgrename`.

---

## 2. Установка зависимостей
- Установлены PHP и модули: `mbstring`, `xml`, `bcmath`, `curl`, `zip`, `mysql`.
- Установлены: `composer`, `git`, `curl`, `unzip`.

---

## 3. Установка Laravel
- Laravel установлен через Composer в `/var/www/app02`.
- Права на папку `app02` выданы `www-data`.

---

## 4. Apache + VirtualHost
- Создан конфиг `app02.conf` с `ServerName app02.local` и `DocumentRoot /var/www/app02/public`.
- Активирован сайт: `a2ensite app02`, отключен дефолт: `a2dissite 000-default`.
- Включен модуль `rewrite`.
- Apache перезапущен и перезагружен.

---

## 5. Подключение к БД
- В `.env` Laravel указаны параметры подключения к внешнему MySQL (`10.100.93.8`).
- На сервере DB создан пользователь `laravel_user` с доступом с IP `10.100.93.6`.
- Установлен `mysql-client` и протестировано подключение к БД.

---

## 6. Завершение и миграции
- При изменении параметров `.env`, необходимо выполнить:
```bash
php artisan config:clear
php artisan config:cache
php artisan migrate
```

---

## 🛠️ Использованные технологии
- Linux Ubuntu
- LVM (pvcreate, vgcreate, lvcreate)
- ext4 файловая система
- Apache2 (a2ensite, VirtualHost, rewrite)
- PHP 7.x+ и модули
- Composer
- Laravel
- MySQL сервер и клиент
- Systemd (systemctl)

---

## 📌 Важные команды

### LVM
```bash
fdisk /dev/sdb
pvcreate /dev/sdb1
vgcreate vg_app2 /dev/sdb1
lvcreate -n www -L 5G vg_app2
mkfs.ext4 /dev/vg_app2/www
echo '/dev/vg_app2/www /var/www ext4 defaults 2 0' | sudo tee -a /etc/fstab
mount -a
```

### Laravel
```bash
composer create-project laravel/laravel app02
sudo chown -R www-data:www-data /var/www/app02
```

### Apache
```bash
a2dissite 000-default.conf
a2ensite app02.conf
a2enmod rewrite
systemctl reload apache2
```

### DB
```bash
mysql -h 10.100.93.8 -u laravel_user -p
```

### Laravel настройки и миграции
```bash
php artisan config:clear
php artisan config:cache
php artisan migrate
```
