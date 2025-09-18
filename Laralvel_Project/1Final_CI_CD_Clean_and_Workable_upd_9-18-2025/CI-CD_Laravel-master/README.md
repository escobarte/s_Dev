# CI-CD Laravel Project "Blog"
```
10.100.93.7 - is used for stages: Building and Deploy-Test
10.100.93.6 - is used for stage: Prod
10.100.93.6:81 - is used for Harbor.
```
## Intro
This project was created only for study scopes.

# Add docker rights for gitlab-runner manually on server
```
sudo usermod -aG docker gitlab-runner
sudo systemctl restart gitlab-runner
sudo getent group docker | grep gitlab-runner
sudo -u gitlab-runner docker ps
```

### Registered 2 runners in gitlab
```
ci,test_deploy for 93.7
prod-only for 93.6
```

