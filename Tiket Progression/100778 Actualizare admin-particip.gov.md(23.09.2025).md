# Before GIT Update

# After GIT pull file that was updated, change owner 
`chown -R www-data:www-data .`
**git pull result** 
```
remote: Total 20 (delta 9), reused 0 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (20/20), done.
From https://git.itsec.md/cs/particip/admin-particip
 * branch            test       -> FETCH_HEAD
   60e6448..c1c6f31  test       -> origin/test
Updating 60e6448..c1c6f31
Fast-forward
 app/Http/Controllers/Particip/DocumentsController.php | 3 +++
 public/admin/app.js                                   | 2 +-
 public/admin/app.json                                 | 2 +-
 public/admin/app.jsonp                                | 2 +-
 public/air/app.js                                     | 2 +-
 public/air/app.json                                   | 2 +-
 public/air/app.jsonp                                  | 2 +-
 public/main/app.js                                    | 2 +-
 public/main/app.json                                  | 2 +-
 public/main/app.jsonp                                 | 2 +-
 10 files changed, 12 insertions(+), 9 deletions(-)
 ```


**storage/logs și  public/particip**

**ll /DATA/participadmin.gov.md/htdocs/storage/**
```sh
drwxrwxrwx 10 www-data www-data 4096 Jun  9 11:07 ./
drwxr-xr-x 11 www-data www-data 4096 Sep 22 14:11 ../
drwxrwxrwx  3 www-data www-data 4096 Oct  5  2020 anexe/
drwxrwxrwx  5 www-data www-data 4096 Oct  5  2020 ckfinder/
drwxrwxrwx  2 www-data www-data 4096 Oct  1  2020 correspondence/
drwxrwxrwx  5 www-data www-data 4096 Sep 22  2020 framework/
drwxrwxrwx  2 www-data www-data 4096 Sep 23 05:00 logs/
drwxrwxrwx  3 www-data www-data 4096 Oct 22  2020 particip/
drwxrwxrwx  2 www-data www-data 4096 Jun 18 09:41 tmp/
drwxrwxrwx  5 www-data www-data 4096 Sep 22  2020 uploads/
```

**ll /DATA/participadmin.gov.md/htdocs/storage/logs/**
```sh
drwxrwxrwx  2 www-data www-data   4096 Sep 23 05:00 ./
drwxrwxrwx 10 www-data www-data   4096 Jun  9 11:07 ../
-rw-r--r--  1 www-data www-data     13 Jul 29  2019 .htaccess
-rw-r--r--  1 www-data www-data 554994 Sep  9 21:56 laravel-2025-09-09.log
-rw-r--r--  1 www-data www-data 537464 Sep 10 09:44 laravel-2025-09-10.log
-rw-r--r--  1 www-data www-data 230370 Sep 11 09:00 laravel-2025-09-11.log
-rw-r--r--  1 www-data www-data 524432 Sep 12 09:00 laravel-2025-09-12.log
-rw-r--r--  1 www-data www-data 524655 Sep 13 09:00 laravel-2025-09-13.log
-rw-r--r--  1 www-data www-data 524655 Sep 14 09:00 laravel-2025-09-14.log
-rw-r--r--  1 www-data www-data 547581 Sep 15 15:54 laravel-2025-09-15.log
-rw-r--r--  1 www-data www-data  70523 Sep 16 21:24 laravel-2025-09-16.log
-rw-r--r--  1 www-data www-data 949333 Sep 17 19:01 laravel-2025-09-17.log
-rw-r--r--  1 www-data www-data 241617 Sep 18 09:00 laravel-2025-09-18.log
-rw-r--r--  1 www-data www-data 525304 Sep 19 09:00 laravel-2025-09-19.log
-rw-r--r--  1 www-data www-data 525304 Sep 20 09:00 laravel-2025-09-20.log
-rw-r--r--  1 www-data www-data 525529 Sep 21 09:00 laravel-2025-09-21.log
-rw-r--r--  1 www-data www-data 569422 Sep 22 14:15 laravel-2025-09-22.log
-rw-rw-rw-  1 www-data www-data 525754 Sep 23 09:00 laravel-2025-09-23.log
```

**ll /DATA/participadmin.gov.md/htdocs/public/**
```sh
drwxrwxrwx  7 www-data www-data  4096 Jan 24  2021 particip/
```


**ll /DATA/participadmin.gov.md/htdocs/public/particip/**
```sh
drwxrwxrwx  7 www-data www-data 4096 Jan 24  2021 ./
drwxrwxr-x 11 www-data www-data 4096 Aug 11 09:38 ../
drwxrwxrwx 10 www-data www-data 4096 Sep 22 11:47 anexe/
drwxrwxrwx  6 www-data www-data 4096 Aug  6 18:29 ckfinder/
drwxrwxrwx  2 www-data www-data 4096 Nov 26  2020 comment_attachments/
drwxrwxrwx  5 www-data www-data 4096 Jan 24  2021 files/
drwxrwxrwx 36 www-data www-data 4096 Nov 10  2020 old/
```

 ```

**ll public/particip/anexe/**
```
drwxrwxrwx   10 www-data      www-data        4096 Sep 22 11:47 ./
drwxrwxrwx    7 www-data      www-data        4096 Jan 24  2021 ../
drwxrwxrwx    4 www-data      www-data        4096 Aug  2  2024 resource_109/
drwxr-xr-x    5 participadmin participadmin   4096 Sep 22 13:23 resource_111/
drwxrwxrwx    8 www-data      www-data        4096 Aug  5 17:18 resource_112/
drwxrwxrwx    4 www-data      www-data        4096 Dec 21  2020 resource_113/
drwxrwxrwx 5454 www-data      www-data      139264 Sep 23 09:52 resource_114/
drwxrwxrwx    7 www-data      www-data        4096 Nov  9  2020 resource_115/
drwxrwxrwx   12 www-data      www-data        4096 Feb  9  2021 resource_143/
drwxrwxrwx    6 www-data      www-data        4096 Nov 20  2020 resource_144/

```
**ll public/particip/anexe/resource_111**
```
drwxr-xr-x  5 participadmin participadmin 4096 Sep 22 13:23 ./
drwxrwxrwx 10 www-data      www-data      4096 Sep 22 11:47 ../
drwxr-xr-x  2 participadmin participadmin 4096 Sep 22 14:09 record_10690/
drwxr-xr-x  2 participadmin participadmin 4096 Sep 22 14:15 record_11299/
drwxr-xr-x  2 participadmin participadmin 4096 Sep 22 12:08 record_13486/
```