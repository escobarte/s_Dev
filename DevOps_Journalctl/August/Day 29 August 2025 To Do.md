# Day 29 of August 
1.[+]Insatll Runner on 10.100.93.6 && 10.100.93.7
```
# Add official GitLab Runner APT repo
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
# Install runner
sudo apt update && sudo apt install -y gitlab-runner
# Check version
gitlab-runner --version
sudo gitlab-runner register
# Ensure service is enabled and running
sudo systemctl enable --now gitlab-runner
sudo gitlab-runner status
sudo gitlab-runner list
```
2.[+]First pipeline for checking runner [smoke]
```
stages: [smoke]

smoke:hello:
  stage: smoke
  image: alpine:3.20
  tags: ["cicd"]   # если твой раннер с тегом — раскомментируй и подставь свой
  script:
    - echo "CI is alive on $(date)"
    - echo "Hello Sergiu.Cusnir"
    - echo "==> OS info"; cat /etc/os-release
```
--- UPD ---
Что я делаю сейчас?
После диалогов с Calude.ai пришёл к выводу, что я буду использовать мой уже говотовый docker compose. И на его базе поднимать CI.