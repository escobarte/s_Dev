CS-RSAL-Prod

10.25.11.3 APP

10.25.14.3 DB

Request:

```
1. În sistemul de operare a serverului este instalat supervisor si serviciul ruleaza(comanda service supervisor status).
2.  Configurația pentru worker-ul laravel este prezenta, de obicei se afla in mapa /etc/supervisor/conf.d si fisierul de obicei e denumit laravel-worker.conf 
Exemplu de configurație transmit anexat, este nevoie doar de ajustat variabilele.
3. Se va verifica statutul worker-ului laravel cu comanda supervisorctl status all, in drept cu denumirea worker-ului trebuie sa fie statutul RUNNING.
4. Verificare ca executarea cronjob-urilor laravel este configurata:
Fiind autentificat cu utilizatorul sub care ruleaza serverul apache, se va rula comanda crontab -e.
In output trebuie sa fie o inregistrare de acest fel:
* * * * * php /{path-to-your-project}/artisan schedule:run >> /dev/null 2>&1
In loc de {path-to-your-project} trebuie sa fie DOCUMENT_ROOT al site-ului rsal.gov.md.
5. Se va verifica daca dupa indeplinirea la toate verificarile de mai sus in jurnalul de executie al job-ului de generare a raportului nu sunt raportate erori, se afla in fisierul storage/logs/cron/verifyfinalreportstatus.txt
6. Daca toti pasii de mai sus nu vor da rezultat pentru debug v-om avea nevoie de urmatoarele:
·         Archiva fisierelor din mapa storage/logs;
·         Datele tabelelor jobs_log, failed_jobs si schedule_logs;
·         Rezultatul executării comenzii(printscreen) ls -la in mapa storage/report si sub ce utilizator ruleaza web-serverul.
```

1. **supervisorctl status**

2. **/etc/supervisor/conf.d/larave-worker**

Left the config of worker as it was, just add missing informaiton like, *stdout_logfile*

```
[program:admin-rsal-laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /home/admin.rsal.site/htdocs/artisan queue:work --queue=high,normal,low --timeout=600 --sleep=3 --tries=1
stdout_logfile=/home/admin.rsal.site/logs/worker.log
autostart=true
autorestart=true
user=admin-rsal
numprocs=1
redirect_stderr=true
```

**Correct resutl**

```[program:laravel-worker]
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=/usr/bin/php /DATA/rsal.gov.md/htdocs/artisan queue:work --queue=high,normal,low --timeout=3600 --sleep=3 --tries=2
stdout_logfile=/DATA/rsal.gov.md/logs/worker.log
autostart=true
autorestart=true
user=www-data
numprocs=2
redirect_stderr=true
```

3. **Supervisorctl**
   
   ```shell
   supervisorctl reread
   supervisorctl update
   supervisorctl restart
   supervisorctl status or watch -n2 supervisorctl status
   ```

4. **Check and updated crontab for www-data**
   
   ```
   sudo crontab -u www-data -e
   * * * * * /usr/bin/php /DATA/rsal.gov.md/htdocs/artisan schedule:run >> /dev/null 2>&1
   ```

   sudo crontab -u www-data -l | grep artisan

```
5. **Check file**
```

cat /DATA/rsal.gov.md/htdocs/storage/logs/cron/verifyfinalreportstatus.txt

```
*if there is no information provide them infor as requested*



# Archi copy and other tasks:

Archive
```

sudo tar -czf /tmp/storage-logs-$(date +%Y%m%d-%H%M%S).tar.gz logs/

```
Copy from Server to local 

```bash
# This step you are doing from WSL, from Local pc
ssh 10.25.11.3 "ls -lh /tmp/*.tar.gz" # List the file from server
scp 10.25.11.3:/tmp/storage-logs-20251010-131852.tar.gz /mnt/d/s_Dev # Passwrod: from IPA
```

Dump for tables in db

**[ChatGPT](https://chatgpt.com/c/68e8e744-38ac-8331-97fc-cc3413e6dabe)**

```shell
sudo -i -u postgres psql # if you need to connect to psql db
sudo -i -u postgres pg_dump -d rsal -t jobs_log > failed_jobs.sql
sudo -i -u postgres pg_dump -d rsal -t failed_jobs > failed_jobs.sql
sudo -i -u postgres pg_dump -d rsal -t schedule_logs > schedule_logs.sql
# Then I did scp to local PC
```
