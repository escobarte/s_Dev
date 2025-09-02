-----------------------------------------

**Install Guide Instructions**

**Docker Engine & Compose / Volumes on LVM **
-----------------------------------------


### Installign Docker Engine + Compose

```
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu noble stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker --version
docker compose version
```

### Move Docker volumes to LVM

```
lsblk
parted /dev/sda/ print free
fdisk /dev/sda
[n,8,enter,+15G,t,8e,w]
pvcreate /dev/sda8
vgcreate DOCKER_FAM /dev/sda8
lvcreate -n lv -L 14.9G DOCKER_FAM
mkfs.ext4 /dev/DOCKER_FAM/lv
nano /etc/fstab
add this: /dev/DOCKER_FAM/lv /var/lib/docker ext4 defaults 0 2
mount -a
```

```
docker info | grep "Docker Root Dir"
df -TH /var/lib/docker
```