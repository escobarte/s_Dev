# 2nd January -- Collecting Linux Commands

```sh
# Example of GREP usage
grep -i "error\|exception\|timeout" /DATA/rsal.gov.md/htdocs/storage/logs/laravel-2025-12-29.log

systemctl list-units --type=service --state=running

echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null # Clear CACHED RAM Memmory

apt-get auto remove / apt-get auto clean

fuser -l # force quite
fuser -kum # k -kill / u -user / m -mount

ps -eo pid,cmd,rss,pmem --sort=-rss | awk '{if ($4 > 0) $4=$4/1024 "MB"; print $1,$2,$4}' | head -n 20 # Show actually RAM ussage

parted /dev/sdb print free

:set number # in VIM to see line numbers

# This is how to do shorter prefix till the $
	PROMPT_DIRTRIM=2
	export PS1="\[\033[01;33m\]\W\[\033[00m\]$ "
	source ~/.bashrc

	export PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
	export LS_COLORS=$LS_COLORS:'ow=30;42:di=01;36:'

# df -h
dh -h / --max-depth=1 2>/dev/null
du -h /var/ --max-depth=1 2>/dev/null | sort -hr
du -h /var/lib --max-depth=1 2>/dev/null | sort -hr | grep -v "^0"


journalctl --disk-usage # space logs are curently used
journalctl --rotate # forces the current active log to close and archive
journalctl --vacuum-size=500M
journalctl --vacuum-time=7d

history | awk '{$1=""; print substr($0,20)}'  #Print history with only code

git log --oneline

netstat -tulnp # Active internet connections
iptables -L -n -v
iptables -L -n -v --line-numbers


# FUN Timer # -------
seconds=180; while [ $seconds -gt 0 ]; do echo -ne "Time remaining: $seconds\033[0K\r"; sleep 1; : $((seconds--)); done; echo "Timer Finished!"
# FUN Timer # -------
```

# Example of adding ssh keys into .ssh dirrectory, and meet issue with rights to files. 
```sh
#Load key "/home/scusnir/.ssh/id_rsa_scusnir": bad permissions
>> chmod 600 /home/scusnir/.ssh/id_rsa_scusnir
```

# Issue with adding the VM to Rancher Cluster. Network issues and also several dockers running on background. 
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