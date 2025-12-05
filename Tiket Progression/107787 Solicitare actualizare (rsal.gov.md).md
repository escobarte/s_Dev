# Actualizare << rsal.gov.md >>

## Servers

CS-RSAL-01APP01P == 10.25.11.3
CS-RSAL-01DB01P  == 10.25.14.3

## Login

I loging using ssh 10.25.11.3
Credentials from <<freeIPA>>

## vSphere Snapshots

```
Va rugam sa efectuati actualizare din GIT de la STISC
https://git.itsec.md/cs/rsal/rsal-site
branchul TEST
am fixat cu MPASS logarea
```

## Steps

1. cd /DATA/rsal.gov.md/htdocs
2. git pull
3. chown -R www-data:www-data /DATA/rsal.gov.md/htdocs/ OR (separately evry line that was changed after update)
4. VERIFY:
   - owner for changed files
   - owner /DATA/rsal.gov.md/htdocs/storage/report