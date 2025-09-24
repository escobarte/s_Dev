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

**[GitHub - muesli/duf: Disk Usage/Free Utility - a better &#39;df&#39; alternative](https://github.com/muesli/duf)**

```visual-basic
apt install duf 
duf 
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ 8 local devices                                                                                             │
├─────────────────────┬───────┬─────────┬────────┬───────────────────────────────┬──────┬─────────────────────┤
│ MOUNTED ON          │  SIZE │    USED │  AVAIL │              USE%             │ TYPE │ FILESYSTEM          │
├─────────────────────┼───────┼─────────┼────────┼───────────────────────────────┼──────┼─────────────────────┤
│ /                   │ 11.4G │   10.6G │ 822.2M │ [##################..]  93.0% │ xfs  │ /dev/OS/root        │
│ /boot               │  1.4G │  252.6M │   1.2G │ [###.................]  17.2% │ xfs  │ /dev/sda2           │
│ /opt/harbor-data    │ 23.5G │  228.5M │  22.0G │ [....................]   1.0% │ ext4 │ /dev/vg_harbor-HARB │
│                     │       │         │        │                               │      │ OR-/STORAGE         │
│ /tmp                │  2.9G │  169.2M │   2.8G │ [#...................]   5.6% │ xfs  │ /dev/OS/tmp         │
│ /var/lib/docker     │  8.8G │    3.1G │   5.2G │ [#######.............]  35.4% │ ext4 │ /dev/docker/storage │
│ /var/lib/elasticsea │ 14.6G │ 1010.9M │  12.8G │ [#...................]   6.8% │ ext4 │ /dev/elastic/search │
│ rch                 │       │         │        │                               │      │                     │
│ /var/log            │  3.9G │  233.2M │   3.7G │ [#...................]   5.8% │ xfs  │ /dev/OS/var_log     │
│ /var/www            │  6.8G │    8.0K │   6.4G │ [....................]   0.0% │ ext4 │ /dev/vg_app02/www   │
╰─────────────────────┴───────┴─────────┴────────┴───────────────────────────────┴──────┴─────────────────────╯
```

**Serching what folders and files take up space**

```bash
dh -h / --max-depth=1 2>/dev/null
du -h /var/ --max-depth=1 2>/dev/null | sort -hr
du -h /var/lib --max-depth=1 2>/dev/null | sort -hr | grep -v "^0"

7.1G    /var/
4.8G    /var/lib
2.2G    /var/cache
124M    /var/log
1.9M    /var/backups
4.0K    /var/www
4.0K    /var/tmp
```

# In case you need to DELETE something fast

```bash
apt clean
apt autoremove
apt autoclean

journalctl --vacuum-time=7d
```

**How to check and idetify RAM**

```bash
free -h 


               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       3.4Gi       270Mi        19Mi       454Mi       366M
```

```bash
ps aux --sort=-%mem | head -15


USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
elastic+ 2569523  3.0 65.4 6998604 2592184 ?     Sl   06:48   3:36 /usr/share/elasticsearch/jdk/bin/java

 #After I stopped and Disabled Elasticsearch process.
```

```bash
echo "🔍 MEMORY USAGE BREAKDOWN:" && ps aux --sort=-%mem | head -8 | awk 'NR>1 {mb=int($6/1024); printf "%s: %dMB (%.1f%%)\n", ($11~/elasticsearch/ ? "Elasticsearch" : ($11~/docker/ ? "Docker" : ($11~/php/ ? "PHP" : $11))), mb, $4}' && echo "" && free -h
```

# How to check Docker how much take

```bash

```