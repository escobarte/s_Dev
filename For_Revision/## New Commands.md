## New Commands

```
curl -vk https://git-dev.itsec.md/api/v4/runners/verify - **send a request to an API Endpoint and curl try to access it verbous and with insecure flag, that proceed even if connection is insecure**

nc -vz git-dev.itsec.md 443 - ** read and write network connection**
```

curl -vk --header "Authorization: Bearer glrt-ygxsHQZf8JZRZCtQ21CV"   https://git-dev.itsec.md/api/v4/runners/verify

sudo netstat -tulpn | grep ":80"
sudo netstat -tulpn | grep ":443"