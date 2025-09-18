# Harbor Registry && Using in CI CD Project

/-----------------------------------------------------\

### Prerequisitions:

#### Software

```
1. Docker                 > 20.10
2. Docker Compose         > 2.3
3. OpenSSL                 > Latest
```

### Create LVM directory "harbor-data"

```
lsblk
fdisk /dev/sdb
p | n | Enter | +25G | t | 6 | 8e | w |
pvcreate /dev/sdb6
vgcreate vg_harbor /dev/sdb6
lvcreate -n HARBOR-DATA - L 24G vg_harbor
mkdir -p /opt/harbor-data
mount /dev/mapper/vg_harbor-HARBOR--STORAGE /opt/harbor-data/
vi /etc/fstab
/dev/mapper/vg_harbor-HARBOR--STORAGE /opt/harbor-data/ ext4 defaults 2 0
mount -a
systemctl daemon-reload
lsblk
df -hT
```

\-----------------------------------------------------/

=================================================================

# Global Step:1 Preparing "HARBOR"

=================================================================

## Summary: Installing Harbor Registry on server 10.100.93.6 (Prod Server for Our Project). It will be used as repository for CI CD Projects, for builds.

### Harbor installation

```bash
## 1 ## ___ Checing app versions
docker --version
docker compose verison
opnessl version
## if you want to update ONLY specific application
apt install --only-upgrade openssl

## 2 ## ___ Downloading and installing
wget https://github.com/goharbor/harbor/releases/download/v2.6.2/harbor-online-installer-v2.6.2.tgz
tar -xzvf harbor-online-installer-v2.6.2.tgz
cd harbor
### find /opt/harbor-2.14.0/ -name "harbor.yml.tmpl"
### /opt/harbor-2.14.0/make/harbor.yml.tmpl
### cd make
cp harbor.yml.tmpl harbor.yml
```

### Configuration

##### vi harbor.yml

```sh
hostname: 10.100.93.6
http port: 81
#ssl port: 443
# this section was commented
  # The path of cert and key files for nginx
  # certificate: /your/certificate/path
  # private_key: /your/private/key/path
  # enable strong ssl ciphers (default: false)
  # strong_ssl_ciphers: false
harbor_admin_password: Harbor12345
database:
  password: root123
  max_idle_conns: 100
  max_open_conns: 900
  data_volume: /opt/harbor-data
```

#### continue isntallation

```sh
##find /opt/harbor-2.14.0/ -name "install.sh"
## /opt/harbor-2.14.0/make/install.sh
./install.sh
```

#### Access from web: 10.100.93.6:81

`Login: admin`
`passw: Harbor12345`

### Creating user and Project for working this register:

```
Create new user "laravler-project"
Create new Project "laravelproject"| add Members to this Project New Created User 
```

### CLI on Server Harbor 93.6

```
You should Login on Harbor server and Second server to realize tests
```

```
docker login 10.100.93.6:81 <docker logout 10.100.93.6:81>
Username: harbor-admin
Passwd:      Harbor123
```

#### Add insecure registries first on both or how much servers do you have

```
vi /etc/docker/daemon.json <--- adding insecure registries
{
    "insecure-registries": ["10.100.93.6:81"]
}
```

```
`if needs do restart`
docker compose down
systemctl restart docker
docker compose up -d
```

```
docker login 10.100.93.6 (User + Password)
```

#### Test TAG + PUSH ++ REMOVE local image and pull back - For Practice

//First you need to TAG and existed image

```
docker pull hello-world
docker images
docker tag hello-world:latest 10.100.93.6:81/laravelproject/recreated_hello_world:v1

//Now to push it into registry
docker push 10.100.93.6:81/laravelproject/my_hello_world:v1

//Test for Pulling
docker rmi <image> --> if you are on the same server where it was created
docker pull 10.100.93.6:81/laravelproject/my_hello_world:v1
```

##### Add insecure registries to 93.7 server  !!!

==========================================================

# Global Step:2 "Applying in CI CD"

==========================================================

### Insecure Registries and restart services

```sh
echo '{
  "insecure-registries": ["10.100.93.6:81"]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
sudo systemctl restart gitlab-runner
```

### .gitlab-ci.yml

```
#Some git actions
git checkout master
git branch -D develop-updates
git pull origin master
cp .gitlab-ci.yml .gitlab-ci.yml.bak2
vim .gitlab-ci.yml
```

##### All updaets are already inserted .gitlab-ci.yml. You can find all need in this file

`located on D:\s_Dev\Laralvel_Project\CI_CD_Blog_on_Laravel`

`vim .gitlab-ci.yml`

```
variables:
  #DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  #DOCKER_LATEST: $CI_REGISTRY_IMAGE:latest
  HARBOR_REGISTRY: 10.100.93.6:81
  PROJECT_NAME: laravel_project
  DOCKER_IMAGE: $HARBOR_REGISTRY/$PROJECT_NAME/laravel-app:$CI_COMMIT_SHA
  DOCKER_LATEST: $HARBOR_REGISTRY/$PROJECT_NAME/laravel-app:latest

------------------

  before_script:
    - echo "Harbro Registry:" $HARBOR_REGISTRY
    - echo "Project:" $PROJECT_NAME
    - echo "Logging into Registry HARBOR"
    - echo $HARBOR_PASSWROD | docker login -u $HARBOR_USERNAME --password-stdin $HARBOR_REGISTRY
    - echo $HARBOR_PASSWORD | docker login -u $HARBOR_USERNAME --password-stdin $HARBOR_REGISTRY
    - echo $HARBOR_PASSWORD | docker login -u $HARBOR_USERNAME --password-stdin $HARBOR_REGISTRY
```

## Troubleshooting/FAQs:

```
#### FAQs
```

1. Issue with installation:
   Solution: Don't Froget to comment in .harbor.yml all about certificates and HTTPS if you are not using them. 

2. The issue is that Docker is trying to use HTTPS by default, but Harbor is configured for HTTP only.
   The solution: is to configure Docker to allow insecure (HTTP) connections to your Harbor registry.

3. Issue with syntax:
   I did a mistake when created user in Harbor. 

4. Accidentaly i removed user from Harbor. I recreated new one, but appear issue with relogin. Logout can not be, because user not exist.
   Solution:
   `vi ~/.docker/config.json # Remove credentials`

5. Variables empty: "username is empty"
   Solution: As i set in Project Variables, I set them as protected. The issue is that if you are on different bracnh, and the branch is not protected, Those variables can not be used. 

###### FAQ:

Related Links/Resources: 

#### Created/Last_Update:

 • 9/18/2025 Sergiu Cusnir