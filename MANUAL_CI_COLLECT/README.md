# [ Description ]
The Script below is used to manually collect Infrastructure CI information.

## [ Usage ]

1. Login 'root' Account. (or sudo -i)
2. wget -O - https://github.com/infra-se/system/blob/main/MANUAL_CI_COLLECT/get_script.sh?raw=true | bash
```
[root@centos02 ~]# 
[root@centos02 ~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[root@centos02 ~]# 
[root@centos02 ~]# pwd
/root
[root@centos02 ~]# 
[root@centos02 ~]# wget -O - https://github.com/infra-se/system/blob/main/MANUAL_CI_COLLECT/get_script.sh?raw=true | bash


...

HTTP request sent, awaiting response... 200 OK
Length: 840 [text/plain]
Saving to: ‘STDOUT’

100%[=======================================================================================================================================================================>] 840         --.-K/s   in 0s      

2024-01-11 05:32:28 (95.1 MB/s) - written to stdout [840/840]

...

[INFO] Script Download Path : /root/shell/MANUAL_CI_COLLECT 
/root/shell/MANUAL_CI_COLLECT/README.md
/root/shell/MANUAL_CI_COLLECT/get_script.sh
/root/shell/MANUAL_CI_COLLECT/manual_ci_collect.sh

```

3. cd /root/shell/MANUAL_CI_COLLECT
4. Run Script : manual_ci_collect.sh
```
[root@centos02 MANUAL_CI_COLLECT]# 
[root@centos02 MANUAL_CI_COLLECT]# ./manual_ci_collect.sh 
centos02|20230921|innotek GmbH|VirtualBox|CentOS|7.9|3.10.0-1160.el7.x86_64|11th Gen Intel(R) Core(TM) i7-11800H @ 2.30GHz|1|0.475574|18.9727
centos02|VirtualBox|/|555:root:root|/dev/mapper/centos_centos01-root|xfs|17.9824|part|2753|112|24.5804
centos02|VirtualBox|/boot|555:root:root|/dev/sda1|xfs|0.990234|part|143|112|1.27679

... 

centos02|tcp6|:::*|:::22|LISTEN|8079/sshd
centos02|tcp6|:::*|::1:25|LISTEN|1442/master
centos02|VirtualBox|CentOS|7.9|1.8.0.262.b10|4.8.5|2.17|1.0.2k
[root@centos02 MANUAL_CI_COLLECT]# 
```

5. cd logs
```
[root@centos02 MANUAL_CI_COLLECT]# 
[root@centos02 MANUAL_CI_COLLECT]# cd logs
[root@centos02 logs]# 
[root@centos02 logs]# pwd
/root/shell/MANUAL_CI_COLLECT/logs
[root@centos02 logs]# 
[root@centos02 logs]# ls -l
total 28
-rw-r--r--. 1 root root  142 Jan 11 05:17 ci_01.log
-rw-r--r--. 1 root root  187 Jan 11 05:17 ci_02.log
-rw-r--r--. 1 root root  177 Jan 11 05:17 ci_03.log
-rw-r--r--. 1 root root 3494 Jan 11 05:17 ci_04.log
-rw-r--r--. 1 root root   73 Jan 11 05:17 ci_05.log
-rw-r--r--. 1 root root  442 Jan 11 05:17 ci_06.log
-rw-r--r--. 1 root root   63 Jan 11 05:17 ci_07.log
[root@centos02 logs]# 
[root@centos02 logs]# 

```

6. Download the CI Log file under the path /root/shell/MANUAL_CI_COLLECT/logs using SFTP.
