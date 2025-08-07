## ⚙️ Настройка каждой VM (hostname, сети, FreeIPA)

---

### 🧾 1. Установка hostname

```bash
# Пример
hostnamectl set-hostname sas-lab-prx01.gov.ipa
exec bash
hostnamectl  # Проверить результат
```

---

### 📝 2. Редактирование /etc/hosts

```ini
127.0.0.1   localhost
#127.0.1.1 emplate-ubuntu-24

# IPv6 по умолчанию
::1         ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters

# Вставить IP и hostname
10.100.93.3     sas-lab-prx01.gov.ipa sas-lab-prx01
```

---

### 🌐 3. Настройка сети через netplan

```yaml
# vim /etc/netplan/01-netcfg.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    ens192:
      dhcp4: no
      dhcp6: no
      addresses:
        - 10.100.93.3/24
      routes:
        - to: default
          via: 10.100.93.1
      nameservers:
        search:
          - GOV.IPA
        addresses:
          - 172.28.39.31
          - 172.28.39.32
```

```bash
netplan generate
netplan apply
```

#### ☁️ Если используется cloud-init

```bash
# Отключить cloud-init конфигурацию сети
sudo nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

# Добавить:
network: {config: disabled}

# Переименовать текущий netplan-файл cloud-init
mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak
```

---

### 🔐 4. Удалить необходимость ввода пароля для sudo

```bash
sudo visudo

# Добавить в конец:
tenantadmin ALL=(ALL) NOPASSWD:ALL
```

---

### 🧩 5. Подключение к FreeIPA

```bash
# Удаление старого клиента
ipa-client-install --uninstall

# Установка клиента
apt install freeipa-client -y

# Простая регистрация
ipa-client-install --mkhomedir

# Принудительная регистрация (если необходимо)
ipa-client-install \
  --mkhomedir \
  --domain=gov.ipa \
  --realm=GOV.IPA \
  --server=dc1.gov.ipa \
  --hostname=`hostname`
```
