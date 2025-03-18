## [ 설명 ]
이 Script는 KISA 한국인터넷진흥원에서 배포/관리하는 UNIX/LINUX 계열 OS 취약점 진단/조치 가이드 72개 항목에 대한 자동화 진단 및 조치를 수행하는 Script 입니다.
현재 20개 항목에 대해서 자동화 조치 구현 완료하였고, 지속적으로 Code 변경 중에 있습니다.

## [ 사용법 ]

1. 시스템에 root 로 Login 하거나 root 스위칭을 합니다. (or sudo -i)
2. 다음과 같은 명령을 활용해 Script를 Download 및 설치 합니다.

wget -O - https://github.com/infra-se/system/blob/main/KISA_SECURITY/get_script.sh?raw=true | bash
```
[root@centos01 ~]# 
[root@centos01 ~]# id
uid=0(root) gid=0(root) groups=0(root)
[root@centos01 ~]# 
[root@centos01 ~]# pwd
/root
[root@centos01 ~]# 
[root@centos01 ~]# 
[root@centos01 ~]# wget -O - https://github.com/infra-se/system/blob/main/KISA_SECURITY/get_script.sh?raw=true | bash

...

HTTP request sent, awaiting response... 200 OK
Length: 1746 (1.7K) [text/plain]
Saving to: ‘STDOUT’

100%[=============================================================================>] 1,746       --.-K/s   in 0s      

2025-03-11 20:51:49 (46.2 MB/s) - written to stdout [1746/1746]


[INFO] Script Path Initialize : /root/shell/KISA_SECURITY 
Cloning into 'system'...
remote: Enumerating objects: 569, done.
remote: Counting objects: 100% (55/55), done.
remote: Compressing objects: 100% (21/21), done.
remote: Total 569 (delta 43), reused 34 (delta 34), pack-reused 514 (from 1)
Receiving objects: 100% (569/569), 179.66 KiB | 0 bytes/s, done.
Resolving deltas: 100% (333/333), done.

[INFO] Script Download Path : /root/shell/MANUAL_CI_COLLECT 
/root/shell/KISA_SECURITY/common
/root/shell/KISA_SECURITY/sec_std_conf.sh

[root@centos01 ~]# 
[root@centos01 ~]#
```
