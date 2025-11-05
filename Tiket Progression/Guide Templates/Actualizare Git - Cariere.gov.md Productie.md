### Title:
# Actualizarea cariere.gov.md **Productie** din GIT

## Summary:

##### Pe git.itsec.md, gasesti repozitoriu cu updates.
*https://git.itsec.md/cs/cariere/cariere.gov.md*

### Prerequisites:

10.25.15.4 - DB/TEST (particip-admin)
10.25.15.3 - Prod    (particip)
10.25.15.2 - Nginx



**10.25.11.12 - CS-Cariere-01SRV01P**
*10.100.168.2 - CS-Cariere-01SRV01D*


#### Step 1:
**Create SNAPSHOTS first.**

#### Step 2:
*ps aux |grep cariere*
*.git is located at /var/www/cariere.gov.md*

```
cd /var/www/cariere.gov.md
git remote -v # to be sure that is correct link to git
git branch # one more check
---
git pull 
# Don't forget to change ownership for file updated
chown -R www-data:www-data public/ # As example from preious git update

```

### **Remove snapshot in 48H**

#### Troubleshooting/FAQs:


Related Links/Resources: 
 • 
 • 

#### Last Updated:

 • 10/28/2025 Sergiu Cusnir