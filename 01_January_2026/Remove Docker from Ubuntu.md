# To completely remove Docker from your Ubuntu server so that no trace of its images, containers, or configurations remains, you need to purge the packages and manually delete the data directories it leaves behind.

```sh
docker stop $(docker ps -aq) 2>/dev/null
docker system prune -a --volumes -f
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf ~/.docker
sudo groupdel docker
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/keyrings/docker.asc
sudo apt-get autoremove -y
sudo apt-get autoclean
docker --version
```