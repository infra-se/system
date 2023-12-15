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

3. change_oom_score.sh
```
[root@centos01 management_os]# 
[root@centos01 management_os]# ./change_oom_score.sh 
[INFO] centos01 Target does not exist. : altibase
[INFO] centos01 Target does not exist. : oracle
[INFO] centos01 Change OOM Score PID : mysqld / 8641
[INFO] centos01 Change OOM Score PID : mysqld / 8806
[INFO] centos01 mysqld / 8810 OOM Score OK.
[INFO] centos01 mysqld / 8811 OOM Score OK.
[INFO] centos01 mysqld / 8812 OOM Score OK.
[INFO] centos01 mysqld / 8813 OOM Score OK.
[INFO] centos01 mysqld / 8814 OOM Score OK.
[INFO] centos01 mysqld / 8815 OOM Score OK.
[INFO] centos01 mysqld / 8816 OOM Score OK.
[INFO] centos01 mysqld / 8817 OOM Score OK.
[INFO] centos01 mysqld / 8818 OOM Score OK.
[INFO] centos01 mysqld / 8819 OOM Score OK.
[INFO] centos01 mysqld / 8820 OOM Score OK.
[INFO] centos01 mysqld / 8821 OOM Score OK.
[INFO] centos01 mysqld / 8822 OOM Score OK.
[INFO] centos01 mysqld / 8823 OOM Score OK.
[INFO] centos01 mysqld / 8824 OOM Score OK.
[INFO] centos01 mysqld / 8825 OOM Score OK.
[INFO] centos01 mysqld / 8833 OOM Score OK.
[INFO] centos01 mysqld / 8834 OOM Score OK.
[INFO] centos01 Target does not exist. : postgres
[root@centos01 management_os]# 
```

4. check_ethernet_info.sh
```
[root@centos01 management_os]# 
[root@centos01 management_os]# ./check_ethernet_info.sh 
[CHECK_RESULT] centos01 enp0s3 08:00:27:3e:f2:47 192.168.137.10/24 SINGLE UP 
[CHECK_RESULT] centos01 enp0s8 08:00:27:05:fa:5e 192.168.100.100/24 SINGLE UP 
[root@centos01 management_os]# 
```

5. check_web.sh
```
[root@centos01 management_os]# 
[root@centos01 management_os]# ./check_web.sh 

Usage1 - ./check_web.sh [List File]
ex1) - ./check_web.sh list

[root@centos01 management_os]# 
[root@centos01 management_os]# 
[root@centos01 management_os]# cat list
google.com
naver.com
142.250.198.14
192.168.137.10
192.168.137.20
[root@centos01 management_os]# 
[root@centos01 management_os]# 
[root@centos01 management_os]# ./check_web.sh list

========================= HTTP OK =========================
HTTP Code 301 OK - google.com
HTTP Code 301 OK - naver.com
HTTP Code 301 OK - 142.250.198.14
======================== HTTP Fail ========================
(Response Server Error Code)
HTTP Code 403 Fail - 192.168.137.10
===================== HTTP Not Listen =====================
(Not Response or Connection Timeout)
HTTP Not Listen - 192.168.137.20

[root@centos01 management_os]#
```

6. user_define_fd_cnt.sh
```
[root@centos01 management_os]# 
[root@centos01 management_os]# ./user_define_fd_cnt.sh 

### 1. Please Input : System Account Name ###

Usage ex) : ./user_define_fd_cnt.sh root

[root@centos01 management_os]# 
[root@centos01 management_os]# ./user_define_fd_cnt.sh apache
PID(9072) FD Count : 41
PID(9073) FD Count : 41
PID(9074) FD Count : 41
PID(9075) FD Count : 41
PID(9076) FD Count : 41
### USER (apache) Total FD : 205 ###
[root@centos01 management_os]# 
```
