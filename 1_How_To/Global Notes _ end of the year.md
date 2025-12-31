
 git log --oneline 

 history | awk '{$1=""; print substr($0,20)}'  *#Print history with only code*

```
export PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
export LS_COLORS=$LS_COLORS:'ow=30;42:di=01;36:'
```
 echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null   *#Clear cached memmory*

 ps -eo pid,ppid,cmd,rss,pmem --sort=-rss | awk '{if ($4 > 0) $4=$4/1024 "MB"; print $0}' | head -n 11  *#Print actualy used RAM*

 ps -eo pid,ppid,cmd,rss,pmem --sort=-rss | head -n 5 

 systemctl list-units --type=service --state=running

 netstat -tulnp

 parted /dev/sdb print free 

# FUN

seconds=180; while [ $seconds -gt 0 ]; do echo -ne "Time remaining: $seconds\033[0K\r"; sleep 1; : $((seconds--)); done; echo "Timer Finished!"
-------------------------------

Load key "/home/scusnir/.ssh/id_rsa_scusnir": bad permissions

>> chmod 600 /home/scusnir/.ssh/id_rsa_scusnir

-------------------------------


## This what I did on 93.7 for preparing VM to add it to cluster
```sh
docker ps
 docker stop 60bdde04a617
 docker stop e11e0e163b39
 docker stop b5abe5706174
 docker ps
 docker ps -a
 free -h
 ll /etc/
 iptables -F
 iptables -X
 systemctl status docker
 swapoff -a
 sed -i '/swap/d' /etc/fstab
 free -h
 netstat -tuln | grep -E '6443|2379|2380|10250'
 swapoff -a
 free -h
 ip a
```


grep -i "error\|exception\|timeout" /DATA/rsal.gov.md/htdocs/storage/logs/laravel-2025-12-29.log




>>> 
ssh -i ~/.ssh/id_rsa_scusnir scusnir@10.100.93.6
>admin
>cDSV0i9JNTi5roel