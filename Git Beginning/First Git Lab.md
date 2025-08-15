# Some notes, review later

# git pull - download

# git push - upload

# git push -u orgin master

## Runners - RUN your Pipeline, an application the pick up and execute CI/CD jobs for GitLab.

### .1. GitLab

`1. Create a project`
`2. Add SSH for push && pull`

....
Install Runner (on Docker) ??? (развёртывание на любой машине)

1. Установил Runner in Docker на `host`
2. Связать `GitLab` and `Runner`
3. Так как `Runner` был запущен в Docker, в дальнейшем ему нужно будет развернуть контейнер в нутри него, по этому при настройке `Runner` - executor: docker (Пока ничего не понятно - но всё со времененм)

`/var/lib/docker/volumesn1-gitlab-runner-config/_data# vi config.toml`
`

#### THis is the start

### Git Lab учеба.

## Сделам `shell-runner` на сервере (про Docker позже)

### Step 1 Installing & Confiugre RUnner

`curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
apt-get install -y gitlab-runner`

On Gitlab.com
Settings -> CI/CD -> Runners -> Create Project Runner 
Add neede info (description: autobot-runner1) 
Information from description will be displayer.

`gitlab-runner register`
`Add url, token, execution:shell (for example)`

## gitlab-runner status

`Runtime platform                                    arch=amd64 os=linux pid=270642 revision=cc489270 version=18.2.1
gitlab-runner: Service is running`

### gitlab-runner list

### SSH Connect

`ssh-keygen -t rsa -b 4096 -C "gitlab_rsa_sergiu"
$when it asks name add this: id_rsa_gitlab`

# nano ~/.ssh/config

`Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile ~/.ssh/id_rsa_gitlab
  IdentitiesOnly yes`

# Provide Rules

`chmod 600 ~/.ssh/id_rsa_gitlab`

# Add Token to Gitlab

# Test connection

`ssh -T git@gitlab.com`

## Clone Repository localy

`cd /mnt/d/s_Dev/Git\ Beginning/
git clone git@gitlab.com:pg13ks.sg/myfirsttest.git
cd myfirsttest/`

# git remote -v

`origin  git@gitlab.com:pg13ks.sg/myfirsttest.git (fetch)
origin  git@gitlab.com:pg13ks.sg/myfirsttest.git (push)`
means: 
`Вывод git remote -v показывает, что ваш локальный репозиторий myfirsttest настроен для взаимодействия 
(fetch): Эта строка означает, что вы можете получать (fetch) изменения из этого удаленного репозитория. Команды, такие как git fetch и git pull, используют этот адрес.
(push): Эта строка означает, что вы можете отправлять (push) свои изменения в этот удаленный репозиторий. Команды, такие как git push, используют этот адрес.`

### Minimal Pipeline

#nano .gitlab-ci.yml

```
stages: [test]

hello:
 stage: test
 tags: [ubuntu_app03] # changed runner 
script:
 - echo "ПРивет Валети из GitLab CI, Runner на серваке 10.100.93.6!"```

git add .gitlab-ci.yml
git commit -m "add your commit"
git push
```

## In gitlab, i saw automated job passed