## 🧩 Уменьшение LVM-раздела и переразметка sda5 + Расширение корня

---

### 🧨 Цель:

- Оставить только **10G** на `/dev/sda5`, где был `/var/www` (LVM).
- Переразметить и восстановить структуру.
- Увеличить корневой раздел `/` за счёт освободившегося места.

---

## 🪛 Step 1: Бэкап данных и остановка сервисов

```bash
systemctl stop apache2
umount /var/www

mkdir /mnt/temp_www_source
mount /dev/mapper/vg_app03-www /mnt/temp_www_source/

mkdir /tmp/backups
rsync -aAXv --delete --info=progress2 /mnt/temp_www_source/ /tmp/backups/var_www_backup_$(date +%Y%m%d_%H%M)

ls /tmp/backups/
ls -lR /mnt/temp_www_source/ | wc -l
```

---

## 🧹 Step 2: Удаление текущей LVM-структуры

```bash
umount /mnt/temp_www_source
rmdir /mnt/temp_www_source/
lvremove /dev/mapper/vg_app03-www
vgremove vg_app03
pvremove /dev/sda5

fdisk /dev/sda  # (p, d, 5) — удалить старый раздел sda5
```

---

## 📐 Step 3: Создание нового раздела sda5 (10G)

```bash
fdisk /dev/sda  # n, p, 5, Enter, +10G, t, 8e, p, w
partprobe /dev/sda
```

---

## 🔁 Step 4: Новая LVM-структура на sda5

```bash
pvcreate /dev/sda5
vgcreate vg_app03 /dev/sda5
vgdisplay vg_app03

lvcreate -n www -L 5G vg_app03
mkfs.ext4 /dev/mapper/vg_app03-www

mkdir -p /var/www/
mount /dev/mapper/vg_app03-www /var/www
```

---

## ♻️ Step 5: Восстановление данных и включение Apache

```bash
rsync -aAXv /tmp/backups/var_www_backup_YYYYMMDD_HHMM/* /var/www/

nano /etc/fstab  # Добавить монтирование
mount -a

systemctl daemon-reload
systemctl enable apache2
systemctl start apache2

lsblk | grep sda5
parted /dev/sda print free
```

---

## ⬆️ Расширение корневого тома `/` за счёт нового PV

### 📊 Проверка свободного места

```bash
lsblk
sudo parted /dev/sda print free
vgs
```

### ➕ Создание /dev/sda6 и расширение VG

```bash
sudo parted /dev/sda mkpart primary 32.2GB 55.2GB
sudo pvcreate /dev/sda6
sudo vgextend OS /dev/sda6
vgs
```

### 🧱 Расширение логического тома и ФС (XFS)

```bash
sudo lvextend -l +100%FREE /dev/OS/root
sudo lvdisplay /dev/OS/root

sudo xfs_growfs /
```

### 📋 Проверка результата

```bash
df -hT /
```
