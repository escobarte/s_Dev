1. Zabbix Monitoring Deployment
	1. Deploy Zabbix on Server
	2. Connect to PostgreSQL external
	3. Configured Zabbix Agents on Monitored Servers
	4. Configured Syntethic Web for Web Checks

 
2. Monitoring Stack (Promtheus - Grafana - Loki)
	1. Deployed Monitoring Stack  
	2. Configured Promtail for logs from NGINX to Loki
	3. Nginx exporter for Metrics
	4. Prometheus Node Exporter and integration with Prometheus
	5. PROMQL configured for monitoring

3. ELK Stack + Filebeats
	1. Deployed Elasticsearch engine for distributed search and analytics
	2. Deployed Logstash as data collection/processing pipeline tool, which send data to Elasticsearch engine.
	3. Deployed Kibana as Visalisator, for interface monitoring.
	4. Deployemnets was proceed on separated servers. 
	5. Deployed and configured File Beat as gathering data.

4. Develop shell scripts:
	1. Backup data for zabbix
	2. Backup dump for databases

5. Ansible used for automated provisiong on server:
	1. Binary build Nginx, ModSecure and GeoIP Modules.

6. GIT
	1. Versioning
	2. CI/CD

7. Docker & Docker Compose

8. CI/CD
	1. 
