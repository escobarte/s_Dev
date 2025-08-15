# Deploy (CD) Laravel Project via GitLab
### 1. Install & Configure Runner
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt install gitlab-runner
sudo systemctl status gitlab-runner
gitlab-runner --version
sudo gitlab-runner register
systemctl start gitlab-runner
systemctl enable gitlab-runner
gitlab-runner list
gitlab-runner verify
sudo usermod -aG sudo gitlab-runner       				 [получает права для выполнения команд с sudo без ввода пароля, что необходимо для автоматизации процессов в GitLab CI/CD.]
sudo -u gitlab-runner whoami
sudo -u gitlab-runner bash -c 'cd /home && ls -la'
```
```
Шаг 1. Дать gitlab-runner sudo без пароля
Выполни на сервере (как root):
# проверить под кем бежит раннер (обычно gitlab-runner)
systemctl cat gitlab-runner | sed -n '1,120p' | grep -i '^User=' || true
# выдать NOPASSWD
echo 'gitlab-runner ALL=(ALL) NOPASSWD:ALL' | tee /etc/sudoers.d/010-gitlab-runner-nopasswd
chmod 440 /etc/sudoers.d/010-gitlab-runner-nopasswd
# быстрый тест: не должен ничего спрашивать
sudo -u gitlab-runner -H bash -lc 'sudo -n true && echo OK || echo FAIL'
```

### 2. Creating 'bootstrap' pipeline, that will prepare server (Apache+PhP+Composer+Node)
#### Will be used ansible-playbook for bootstrap
Repository structure: **(configs you will find in git-dev)**
```
laravel_ci_cd \
	.gitlab-ci.yml
	ansible \
		bootstrap.yml
```

