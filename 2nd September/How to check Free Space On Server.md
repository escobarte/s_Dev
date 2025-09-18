# How to check free Memmory (HDD-SDD) on Server.
```bash
1. lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0   20G  0 disk
 ├─sda1               8:1    0    1M  0 part
 ├─sda2               8:2    0  1.5G  0 part /boot
sdb                  8:16   0   80G  0 disk
 ├─sdb1               8:17   0    8G  0 part
 │ └─vg_app02-www   252:0    0    7G  0 lvm  /var/www

2. parted -s /dev/sdb unit GB print free
```