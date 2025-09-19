# Kubernetes installation on 93.5 

Creating dedicated LVM setup
	```
	parted /dev/sdb print free
	fdisk /dev/sdb
	pvcreate /dev/sdb8
	vgcreate vg_kuber /dev/sdb8
	lvcreate -n netes -l 5887 vg_kuber
	mkfst.ext4 /dev/mapper/vg_kuber-netes
	mkdir -p /opt/kubernetes/{kubelet,containered,etcd}
	mount /dev/mapper/vg_kuber-netes /opt/kubernetes
	vi /etc/fstab
	/dev/mapper/vg_kuber-netes /opt/kubernetes/ ext4 defaults 0 2
	mount -a
	```







Install and configure containerd
```

```