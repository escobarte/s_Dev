## Title:

#### [RVV Update/Deploy] [Actualizare RVV]

## Summary:

##### Pe Server RVV/test este plasat java(zip) care trebuie copiat pe server si rulat script de executare de Deploy.

### Prerequisites:

vSphere
TeamPass
MADRM-RVV-01App01P - 10.100.10.11
MADRM-RVV-01App01TP - 10.100.101.10

### Steps:

Step 1: Snapshot pentru petru serverul 10.100.10.11
Step 2: ssh --> 10.100.10.11
  (din History se poate de luat info ce s-a facut) 
Step 3: executare comenzii scp de pe server 10.100.101.10 pe local
Step 4: rularea scriptului

```shell
scp root@10.100.101.10:/opt/wildfly/standalone/deployments/vwr-ear.ear /tmp/
ll /opt/wildfly/standalone/deployments/
ll /tmp/
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