# 🛠️ DevOps Work Journal: 09–14 July 2025

---

## 📅 Work Day: 09-07-2025

**🖼️ Snapshot:** `10.100.93.6_App02`  
**🔧 Task:** Install Minikube

**📌 Progress:**

- Followed along with training videos.
- Created `yaml` file.
- Deployed a Pod.
- Created a ReplicaSet.

**📊 Focus:** Logging & Monitoring  
**Started Researching:**  

- Grafana  
- Loki  
- Prometheus  
  **📘 New Concepts:** `PromQL`, `Exporters`

---

## 📅 Work Day: 10-07-2025

**🖼️ Snapshot:** `10.100.93.5_App01`  
**📦 Task:** Installing Prometheus + Grafana + Loki

**⚙️ Process:**

- Created logical volumes for:
  - `/grafana`
  - `/loki`
  - `/prometheus`
- Setup `docker-compose.yaml`
- Wrote configuration files
- Performed troubleshooting

**✅ Result:** All services up and running

**📍 Snapshot:** `10.100.93.3` → `10.100.93.4`  
**🛠️ Task:** Install `node_exporter` on both

---

## 📅 Work Day: 11-07-2025

**🖼️ Snapshot:** `10.100.93.3_Nginx01`  
**🔍 Task:** Research how to integrate metrics into Grafana

**🎯 Result:** Understood how to expose metrics using `node_exporter`

**🧠 Key Concept:**  
Use `stub_status` page in Nginx by creating a server block in `/etc/nginx/conf.d/status`

---

## 📅 Work Day: 14-07-2025

### ✅ Recap

**Verified:**

1. Prometheus + Grafana + Loki on `93.5` — ✅ Running
2. `node_exporter` + `nginx-exporter` — ✅ Installed

### 🔍 New Objective

**Task:**  

- Find and configure `nginx-exporter.service`

---

## 🔎 Insights:

- `node_exporter` provides **system metrics only**.
- For Nginx-specific metrics (requests, workers, 4xx/5xx):
  - Use `nginx-exporter`
  - Or Prometheus-module-nginx
  - Or VTS / stub_status endpoint

---

## 📅 Work Day: 29-07-2025

**🖼️ Snapshot:** `10.100.93.4_Nginx01`  
**🔍 Task:** Prepare playbook in Ansible for Nginx + Modsecurity + GeoIP2 and all dependecies

**🎯 Result:** 

**🧠 Key Concept:**  

* **Prepare Playbook for:** Nginx from source code

* **Step Two:** Modules configuring

* **Step Three:** Config files and KeepAlived?
