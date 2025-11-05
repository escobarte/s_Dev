## Title:

#### [RVV Update/Deploy] [Actualizare RVV] [Backup Database]

## Summary:

##### De facut Backup la Baza de Date

##### Pe Server RVV/test este plasat java(zip) care trebuie copiat pe server si rulat script de executare de Deploy.

### Prerequisites:

vSphere
TeamPass
MADRM-RVV-01App01P - 10.100.10.11
MADRM-RVV-01App01TP - 10.100.101.10

### Steps:

**Step Snapshot**: Snapshot pentru petru serverul 10.100.10.11

**Step Backup**: De identificat daca se face backup 
sudo -i
crontab -l 

```
# Backups
0 2 * * * /usr/local/bin/backup_data_db_and_logs.sh >> /var/log/backup_logs.log
50 23 * * * /root/bin/rotate_logs.sh
50 00 * * * /root/bin/postgrebackup.sh
```

[root@rvv ~]# cat /root/bin/postgrebackup.sh

```
Aici se afla script pentru backup la baza de date.
```

Path unde se face backup:

```
ls -lah /mnt/backup/db/
```

Pentru a rula script local actual:

```
sudo -Hiu postgres -H pg_dumpall | gzip > /mnt/backup/db/dump_all-$(date +%Y-%m-%d_%H-%M).sql.gz && echo " All DBs backup succeeded today: $(date +%Y-%m-%d' '%H:%M) " | tee -a /var/log/cronbackup.log || echo "$(date +%Y-%m-%d' '%H:%M) dump FAILED" | tee -a /var/log/cronbackup.log
```

**Step Deploy**
ssh --> 10.100.10.11
  (din History se poate de luat info ce s-a facut) 
executare comenzii scp de pe server 10.100.101.10 pe local
rularea scriptului

```shell
scp root@10.100.101.10:/opt/wildfly/standalone/deployments/vwr-ear.ear /tmp/
ll /tmp/
sudo -i
sudo ./deploy.sh #From root run the script
CTRL + C
```

## Troubleshooting/FAQs:

FAQ:
Acest script dupa pornire ramiine rulat. 
Ctrl +C si ai plecat.  

Related Links/Resources: 
 • 
 • 

#### Last Updated:

 • 9/16/2025 Sergiu Cusnir