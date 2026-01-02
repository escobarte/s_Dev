# Deployment & Security
```ArgoCD: A GitOps continuous delivery tool. It monitors a Git repository (your "source of truth") and automatically synchronizes the state of your Kubernetes cluster to match the code in Git. If someone manually changes a setting in the cluster, ArgoCD will detect the "drift" and revert it to match the Git config.
```

```
Wazuh: An open-source security platform. It provides XDR (Extended Detection and Response) and SIEM (Security Information and Event Management) capabilities. It monitors your infrastructure (including Kubernetes nodes and containers) for threats, detects malware, monitors file integrity, and helps with regulatory compliance.
```

# Quick Comparison Table
Tool		Category			Key Purpose
Rancher		Management			"I want one dashboard to manage all my clusters."
Helm		Packaging			"I want to package my app so it's easy to install."
ArgoCD		Deployment			"I want my cluster to always match my Git code."
Wazuh		Security			"I want to detect hackers and security vulnerabilities."
