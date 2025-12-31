# sudo -u postgres psql


Buna ziua, 
la actelocale.gov.md in baza de date la tabelul acte de facut ajustari direct in postgress, doar asa e posibil. Se logheaza cu user si parola din postgress

si se aplica urmatoarea comanda
ALTER TABLE acte
ALTER COLUMN number TYPE varchar(150);
----------------------
posgres=#

```bash

```


sudo -Hiu postgres pg_dumpall | gzip > /DATA/backups/backup_before_altertable-$(date +%Y-%m-%d).tar.gz


0 2 * * * /usr/local/bin/backup_postgresql.sh > /var/log/backup_postgresql.log
0 1 * * * /usr/local/bin/backup_db_and_logs.sh >> /var/log/backup_db_and_logs.log
#15 21 * * * bash -x /roo/bin/backup.sh
0 0 * * * /root/clean.sh


/DATA/backups/
/var/backup/csb1db01/


su - postgres -c ${PGDUMPALL} > ${BKFOLDER}/rsal_acte-pg-daily-`date +%Y-%m-%d`.sql
 gzip ${BKFOLDER}/rsal_acte-pg-daily-`date +%Y-%m-%d`.sql

 do sudo -Hiu postgres pg_dump $DB | gzip > "/var/backup/csb1db001/daily/$DB-$(date +%Y-%m-%d).sql.gz"
