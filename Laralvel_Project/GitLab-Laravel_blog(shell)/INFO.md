# Stud How to Branches and other shit

## This file was created using nano.

### Last file was created manually, but was untracked.

# Step 1:

I used workflow rules, to separete pipeline execution. 

## Process:

Removing from server 10.100.93.6 /var/www/app02 to see what this pipeline doing.
Updeted: Removed just now (restart)
Updeted: Revert=Snapshot VM Snapshot 8%2f15%2f2025, 12:10:59 PM
Updates: Roll back to previous version of pipeline
Updates: fixed issue with k8s added nopasswd for runner, running initial pipeline for test

# IMPORTANT add NOPASSWD and fix issue with k8s

```
echo "gitlab-runner ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/gitlab-runner
sudo visudo -cf /etc/sudoers.d/gitlab-runner   # проверка синтаксиса
```
