# Description : Linux System Engineering & Infra automation Code

## [ Usage ]
1. all_user_fd_cnt.sh
```
[root@centos01 management_os]# 
[root@centos01 management_os]# ./all_user_fd_cnt.sh 
USER (rpcuser) Total FD : 10
USER (rpc) Total FD : 12
USER (root) Total FD : 395
USER (postfix) Total FD : 24
USER (polkitd) Total FD : 12
USER (ntp) Total FD : 14
USER (libstoragemgmt) Total FD : 5
USER (dbus) Total FD : 16
[root@centos01 management_os]# 
```

2. check_os.sh
```
[root@centos01 management_os]# 
[root@centos01 management_os]# ./check_os.sh 

[  OS Check Result ]
[ Script Version ] : 
[ Platform ] : VirtualBox
[ Hostname ] : centos01 / CentOS Linux release 7.9.2009 (Core) / 3.10.0-1160.el7.x86_64
[ OK ] System Resouce OK. [ CPU ] : 40.10 % [ MEM ] : 44 % [ System Load ] : 0.16 (2 Core System)
[ OK ] All Account Password Not Expires.
[ OK ] NAS or NFS Mount is OK.
[ OK ] All Filesystem Not Read-only.
[ OK ] Filesystem Usage is OK.
[ OK ] Inode Usage is OK.
[ OK ] Filesystem Mount Status OK.
[ OK ] LVM Status OK.
[ OK ] Not Used Multipathd
[ OK ] Used Ethernet All OK
[ OK ] Network Bonding Not Used.
[ Ethernet ] All Network Interface Status

enp0s3 : 	Speed: 1000Mb/s
	Link detected: yes

enp0s8 : 	Speed: 1000Mb/s
	Link detected: yes

Module dstat_nfs3 failed to load. (Cannot open file /proc/net/rpc/nfs)
----system---- ---load-avg--- sda--sdb--sdc- --io/total- ----most-expensive---- --highest-total--
     time     | 1m   5m  15m |util:util:util| read  writ|     i/o process      | cputime process 
15-12 00:06:46|0.46 0.11 0.08|0.03:0.00:0.00|0.33  0.30 |yum          20k 6527B|yum           550
15-12 00:06:47|0.46 0.11 0.08|10.4:   0:   0|   0  73.0 |urlgrabber-   0  1256k|urlgrabber-ex  75
15-12 00:06:48|0.46 0.11 0.08|   0:   0:   0|   0     0 |urlgrabber-   0   964k|urlgrabber-ex  68
15-12 00:06:49|0.46 0.11 0.08|   0:   0:   0|   0     0 |urlgrabber-   0  1500k|urlgrabber-ex 167
15-12 00:06:50|0.46 0.11 0.08|   0:   0:   0|   0     0 |urlgrabber-   0  1088k|urlgrabber-ex 105
15-12 00:06:51|0.67 0.16 0.09|   0:   0:0.10|   0  2.00 |urlgrabber-   0  1024k|urlgrabber-ex 153

[root@centos01 management_os]# 
```

