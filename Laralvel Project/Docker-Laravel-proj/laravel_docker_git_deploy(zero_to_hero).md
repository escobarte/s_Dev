-----------------------------------------

**Laravel Project Docker Git**
-----------------------------------------
`host = 10.100.93.7`

#### Pre - Provisioning
1. Clean old laravel project				**[Done]**
2. Install and configure Runner on server **(Later)**

## Step 1: Docker-Compose (laravel project) directly on server.
### Prerequisition tools:
1. Git  						[installed]
2. Docker Engine + Compose 		[installed]

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

#### Usefull code
```
ll /var/lib/docker

docker info
docker ps -a
docker images -a

docker build -t <image_name>
docker build -t <image_name> . -no-cache
dokcer run -d <image_name>
docker run --name <container_name> <image_name> 	# Run container from a image with custom name

docker rmi <image_name>
docker image prune  								# Remove all unused images
```

### Developing project on Docker
## Stoped here pm 8/22/2025 (needed deeper knowledge first)
