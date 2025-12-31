# Guide how to Clean and Prepare used Server on Ubuntu.

#### Stop Runnig Services
systemctl list-units --type=service --state=running
#### Create script for removing them

```
#!/bin/bash
#Defingin serices
SERVICES=(
        "apache2.service" "containerd.service" "docker.service" "kubelet.service" "node_exporter.service" "zabbix-agent2.service" "nfs-blkmap.service" "nfs-idmapd.service" "nfs-mountd.service" "nfsdcld.service"
)
echo "---- Stoping and Disabling Services -----------"
for SVC in "${SERVICES[@]}"; do
        if systemctl list-units --type=service --state=running | grep -q "$SVC"; then
                echo "[!] Target detected: $SVC. Neutralizing..."
                sudo systemctl stop "$SVC" 2>/dev/null
                suto systemctl disable "$SVC" 2>/dev/null
                sudo systemctl mask "$SVC" 2>/dev/null
        fi
done
echo "----- Releasing RAM Caches----"
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
echo "---- FREE -H-------"
free -h
echo "---Cleanig Package Manager and logs"
echo "APT-GET Autoremove ..."
sudo apt-get autoremove -y > /dev/null
sudo apt-get clean
echo "Cleaning JournalCTL...."
sudo journalctl --vacuum-time=1s
```

`echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null`  #Clear cached memmory

#### Unmount directories from lsblk
```
lsblk
sudo fuser -kum /var/www /srv/nfs /mnt/prometheus_data /mnt/grafana_data /mnt/loki_data /var/lib/etcd /var/lib/kubelet /opt/kubernetes
sudo umount -kum /var/www /srv/nfs /mnt/prometheus_data /mnt/grafana_data /mnt/loki_data /var/lib/etcd /var/lib/kubelet /opt/kubernetes #It kills every single program that is currently touching a specific drive so you can safely unplug it
sudo umount /var/www /srv/nfs /mnt/prometheus_data /mnt/grafana_data /mnt/loki_data /var/lib/etcd /var/lib/kubelet /opt/kubernetes
ps -eo pid,ppid,cmd,rss,pmem --sort=-rss | awk '{if ($4 > 0) $4=$4/1024 "MB"; print $0}' | head -n 11 #Print actualy used RAM
lvremove /dev/vg_app01-www -y
lvremove /dev/vg_app01/www
lvremove /dev/NFS/storage
lvremove /dev/vg_prom/prometheus -y
lvremove /dev/vg_graf/grafana -y
lvremove /dev/vg_lo/loki -y
```

**lvremove /dev/vg_kuber/netes -y**
**!! device-mapper: remove ioctl on vg_kuber-netes  failed: Device or resource busy**
### Troubleshooting tools
```
dmsetup info vg_kuber-netes
dmsetup ls --tree
docker ps -q | xargs docker inspect | grep -i "dm-8\|vg_kuber"
systemctl status containerd docker
cat /proc/*/mountinfo | grep vg_kuber
fuser -vm /dev/vg_kuber/netes
fuser -vm /dev/mapper/vg_kuber-netes
lsof /dev/mapper/vg_kuber-netes
grep -l "272f471033126\|2b32189f2acb0\|8f9efabaefac0\|d526cecbb8cc2\|6005cf5569a84" /proc/*/cgroup 2>/dev/null | cut -d/ -f3 | xargs kill -9
lvremove /dev/vg_kuber/netes -y
Done. 
fdisk /dev/sdb
delete all partitions
parted /dev/sdb print free
```
### --------------------- Another steps how to remove -------------------
 ps -eo pid,ppid,cmd,rss,pmem --sort=-rss | awk '{if ($4 > 0) $4=$4/1024 "MB"; print $0}' | head -n 11
 -- here i found that there is a kibana not needed process
systemctl stop kibana.
systemctl stop kibana
systemctl disable kibana
kill 1559
sudo apt-get remove kibana
apt-get purge kibana
rm -rf /var/lib/kibana/
apt-get purge kibana
apt-get remove kibana
apt-get autoremove && apt-get autoclean
free -h
systemctl status kibana