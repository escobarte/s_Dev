How to install Runner: [Basics]

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

# 1) Скачиваем нужную версию (amd64)

ver="v16.8.1"
sudo curl -fL -o /usr/local/bin/gitlab-runner \
  "https://gitlab-runner-downloads.s3.amazonaws.com/${ver}/binaries/gitlab-runner-linux-amd64"

# 2) Делаем исполняемым

sudo chmod +x /usr/local/bin/gitlab-runner

# 3) Создаём системного пользователя (если нет)

id gitlab-runner 2>/dev/null || sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# 4) Ставим и запускаем как systemd-сервис

sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo systemctl enable --now gitlab-runner

# 5) Проверяем

gitlab-runner --version

-----------------------------------------

# Download and add the GPG key

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt install gitlab-runner
sudo systemctl status gitlab-runner
gitlab-runner --version
sudo gitlab-runner register
systemctl start gitlab-runner
systemctl enable gitlab-runner
gitlab-runner list
gitlab-runner verify
sudo usermod -aG sudo gitlab-runner
sudo -u gitlab-runner whoami
sudo -u gitlab-runner bash -c 'cd /home && ls -la'

```
  Troubleshooting Commands:
bash# Check runner status
sudo systemctl status gitlab-runner
# View logs
sudo journalctl -u gitlab-runner -f
# Restart runner
sudo systemctl restart gitlab-runner
# Check runner configuration
sudo cat /etc/gitlab-runner/config.toml
```