curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt update && sudo apt install -y gitlab-runner
gitlab-runner --version
sudo gitlab-runner register
sudo systemctl enable --now gitlab-runner
sudo gitlab-runner status
sudo gitlab-runner list
sudo gitlab-runner unregister --url https://gitlab.com/ --token abcdef1234567890
sudo gitlab-runner unregister --name "my-runner"
sudo apt remove gitlab-runner
sudo gitlab-runner uninstall