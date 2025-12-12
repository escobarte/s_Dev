# particip.gov.md (GIT Actualizari)
Tiket: 108097

Server Structur:
10.25.15.2 = ProxyServer /etc/nginx/...
10.25.15.3 = admin-particip.gov.md
10.25.15.4 = newparticip.gov.md

 pg_dump -U participadmin -h localhost participadmin > dump_participadmin_$(date +%Y%m%d_%H%M%S).sql

Database on 10.25.15.3 Pentru Ambele (admin+new)


Actualizările din GIT pentru admin-particip.gov.md .
După actualizare: php artisan migrate  (dump db?)
După actualizarea platformei http://admin-particip.gov.md/ se va actualiza platforma particip.gov.md din GIT.
Suplimentar:
Se va asigura că după update aplicațiile au drept de înscriere în mapele storage/logs și  public/particip și toate subdirectoriile acestora

## Step: 1
**Snapshot on:**
CS-PARTICIP-01APP01P
CS-PARTICIP-01DB01P

## Step: 2
**Dump DATABSE**
```
ssh to admin-particip.gov.md.conf == 10.25.15.4 

Login: ssh tenantadmin@10.25.15.4
Password: [[ Temp pass from descriptions ]]

<< To find DB >>

cd /DATA/participadmin.gov.md/htdocs
ll
cat .env | grep DB ( to find login and password )

# Being as root go to Back folders and do DUMP database
cd /DATA/participadmin.gov.md/backups

pg_dump -U participadmin -h localhost participadmin > dump_participadmin_$(date +%Y%m%d_%H%M%S).sql

# Intro password that you found in .env
# Check if dump passed successfully 

ls -alht 
# -rw-r--r--  1 root     root     615M Dec  8 08:05 dump_participadmin_20251208_080515.sql
```

## Step: 3
**GIT actualizare admin-particip.gov.md**
```sh
Login: ssh tenantadmin@10.25.15.4
Password: [[ Temp pass from descriptions ]]

cd /DATA/participadmin.gov.md/htdocs
git pull  <add login and pass>
# after update check files persmissions
# first change ownership for updated files after gir pull 
```
```
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs# chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/public/
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs# chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/vendor/
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs# chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/database/
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs# chown -R www-data:www-data /DATA/participadmin.gov.md/htdocs/app/
```

## Step: 4
**php artisan migrate**
```sh
# Check files before migration
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs/storage/logs# ll
total 5556
drwxrwxrwx  2 www-data www-data   4096 Dec  8 05:00 ./
drwxrwxrwx 10 www-data www-data   4096 Jun  9 11:07 ../
-rw-r--r--  1 www-data www-data     13 Jul 29  2019 .htaccess
-rw-rw-rw-  1 www-data www-data 536646 Nov 24 09:00 laravel-2025-11-24.log
-rw-r--r--  1 www-data www-data 539671 Nov 25 09:00 laravel-2025-11-25.log
-rw-rw-rw-  1 www-data www-data 538223 Nov 26 09:00 laravel-2025-11-26.log
-rw-rw-rw-  1 www-data www-data 548758 Nov 27 11:56 laravel-2025-11-27.log
-rw-rw-rw-  1 www-data www-data 540139 Nov 28 09:00 laravel-2025-11-28.log
-rw-rw-rw-  1 www-data www-data 539123 Nov 29 09:00 laravel-2025-11-29.log
-rw-rw-rw-  1 www-data www-data 539123 Nov 30 09:00 laravel-2025-11-30.log
-rw-rw-rw-  1 www-data www-data 563745 Dec  1 12:07 laravel-2025-12-01.log
-rw-rw-rw-  1 www-data www-data 551651 Dec  2 13:42 laravel-2025-12-02.log
-rw-rw-rw-  1 www-data www-data 689619 Dec  3 15:51 laravel-2025-12-03.log
-rw-rw-rw-  1 www-data www-data   9375 Dec  4 13:28 laravel-2025-12-04.log
-rw-rw-rw-  1 www-data www-data  46981 Dec  5 15:19 laravel-2025-12-05.log
-rw-rw-rw-  1 www-data www-data   1388 Dec  6 15:13 laravel-2025-12-06.log
-rw-rw-rw-  1 www-data www-data     61 Dec  7 05:00 laravel-2025-12-07.log
-rw-rw-rw-  1 www-data www-data     61 Dec  8 05:00 laravel-2025-12-08.log
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs/storage/logs# find /DATA/participadmin.gov.md/htdocs/storage/logs/ -user root

------------------------------------------------------

root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs/public/particip/anexe# ll
total 200
drwxrwxrwx   11 www-data www-data   4096 Dec  3 22:22 ./
drwxrwxrwx    7 www-data www-data   4096 Jan 24  2021 ../
drwxrwxrwx    4 www-data www-data   4096 Aug  2  2024 resource_109/
drwxrwxrwx    7 www-data www-data   4096 Dec  3 21:13 resource_111/
drwxrwxrwx    8 www-data www-data   4096 Aug  5 17:18 resource_112/
drwxrwxrwx    4 www-data www-data   4096 Dec 21  2020 resource_113/
drwxrwxrwx 5789 www-data www-data 159744 Dec  5 00:56 resource_114/
drwxrwxrwx    7 www-data www-data   4096 Nov  9  2020 resource_115/
drwxrwxrwx   12 www-data www-data   4096 Feb  9  2021 resource_143/
drwxrwxrwx    6 www-data www-data   4096 Nov 20  2020 resource_144/
drwxr-xr-x    3 www-data www-data   4096 Dec  3 22:22 resource_153/
root@01PARTICIP02:/DATA/participadmin.gov.md/htdocs/public/particip/anexe# find /DATA/participadmin.gov.md/htdocs/public/particip/ -user root

# Doing Migrations

php artisan migrate

# then simple check files permissions
```


## Step: 5
**GIT actualizare admin-particip.gov.md**

```sh
ssh to admin-particip.gov.md.conf == 10.25.15.3 

Login: ssh tenantadmin@10.25.15.3
Password: [[ Temp pass from descriptions ]]

git pull

chown -R www-data:www-data /DATA/newparticip.gov.md/htdocs/ For all updated files
```