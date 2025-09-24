lsblk
fdisk /dev/sdb
p | n | Enter | +25G | t | 6 | 8e | w |
pvcreate /dev/sdb6
vgcreate vg_harbor /dev/sdb6
lvcreate -n HARBOR-DATA - L 24G vg_harbor
# better alternative for lvcreate (sudo lvcreate -n netes -l 5887 vg_kuber)
mkfs.ext4 /dev/mapper/vg_harbor-HARBOR--STORAGE
mkdir -p /opt/harbor-data
mount /dev/mapper/vg_harbor-HARBOR--STORAGE /opt/harbor-data/
vi /etc/fstab
/dev/mapper/vg_harbor-HARBOR--STORAGE /opt/harbor-data/ ext4 defaults 2 0
mount -a
systemctl daemon-reload
lsblk
df -hT