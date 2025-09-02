## Docker Engine && Docker Compose

```bash
/var/lib/docker     # volumes
docker 
docker ps / docker ps -a
watch -n2 docker ps
docker stop/rm/start 
docker images / docker images -a
docker rmi <image>
docker stats
docker info
docker volume ls

docker build -f Dockerfile.prod -t laravel_blog:latesttag
docker volume create laravel-db

docker run -d --name blog-online -p 8080:80 laravel-db:/var/www/html/database laravel_blog:latesttag
docker exec -it blog-online sh

docker exec -it blog-online ls -la /var/www/html/ | grep -E "(storage|public|bootstrap)"
docker logs <container-name/container-id>
docler logs blog-online | tail -40 / tail -f
```

## Git

```bash
git add . && git commit -m"Some Comments [skip ci] _ $(date +%m-%d_%H-%M-%S)" && git push
git add . && git commit -m"Some Comments [skip ci]" && git push
git commit -m"Comments [skip ci]" = ignore to run Pipeline
git log --oneline --graph --all
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
apt-get install -y gitlab-runner
gitlab-runner status
gitlab-runner list

ssh-keygen -t rsa -b 4096 -C "email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub               # Копируешь на GitHub

```

## Network-ing

```bash
apt install iptables iptables-persistent

nc -vz git-dev.itsec.md 443 - ** read and write network connection**
lsof -i: 8080

netstat -tulpn | grep ":80"
netstat -tulpn | grep ":443"
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -L -n -v --line-numbers
iptables -L INPUT -n --line-numbers
iptables -A INPUT -p tcp -s 10.100.93.5 --dport 5601 -j ACCEPT
netfilter-persistent save
iptables -L INPUT --line-numbers
iptables -D INPUT 2        # удалить правило
iptables -I INPUT 4 ...    # вставить на позицию 4
*/ Rules \*
iptables -L -n -v
iptables -L INPUT --line-numbers
iptables -L FORWARD -n -v
iptables -L DOCKER-USER -n -v
iptables -t nat -L POSTROUTING -n -v
```


## Linux_Commands
```bash
*/ Processes \*
watch -n2 docker ps
history | tail -20 | awk '{$1=""; $2=""; $3=""; print}'
systemctl list-units --type=service --state=running
lsof -i: 8080 											#(list open files)
lsof /var/log/file.log
ps aux | grep Dockerfile								#(process status)
ps -ef
journalctl -u logstash -n20
journalctl -xeu elastichsearch.service
tail -f /var/log/nginx/error.log/nginx/error

*/ Memmory \*
sudo du -bm? /mnt/dns
sudo parted /dev/sdb print free
sudo du -sh /var/...
lsblk -f // df -h //
fdisk -l /dev/sdb
parted /dev/sdb print free

ps aux | grep nginx #process
find / -iname '*nginx*'
systemctl list-units | grep nginx
du -sh /var/log/* | sort -hr                # Сколько весят файлы
iostat                                      # I/O статистика
vmstat                                      # Статистика памяти

df -Th     # типы + размеры в человеко-читаемом виде
df -TG     # типы + строго в гигабайтах
ls -lhtr   # старые файлы сверху
ls -lhSr   # маленькие файлы сверху
ls -lht   # новые файлы по дате изменения
ls -lhu   # новые файлы по дате доступа
ls -lhc   # новые файлы по изменению метаданных
du -sh /var/log/* | sort -hr
du -sh /var/lib/docker/containers
ls -lhSr /var/log/
df -h --total	#общее свободное место на сервере
df -h --total | grep total


/etc/shadow        # Хранит хэши паролей пользователей
/etc/passwd        # Инфо о пользователях (uid, shell и тд)
/etc/group         # Информация о группах
id zabbix          # Инфо о пользователе zabbix

```


## Name_Me
```bash





```


## Name_Me
```





```