## Title:

#### [Actualizarea admin-particip.gov.md din GIT]

## Summary:

##### Pe git.itsec.md, gasesti repozitoriu cu updates.

### Prerequisites:

10.25.15.4 - DB/TEST (particip-admin)
10.25.15.3 - Prod    (particip)
10.25.15.2 - Nginx

Create SNAPSHOTS first.

### Steps:

Steps:
git status
git pull origin test
chown -R www-data:www:data .

chmod -R 777 /DATA/

## Troubleshooting/FAQs:

FAQ:
FAQ1: De verificat ca .../logs/* sa fie (777 si www-data)

Related Links/Resources: 
 • 
 • 

#### Last Updated:

 • 9/16/2025 Sergiu Cusnir