## [ Release info ]  
2025.04.18. Script Version 1.1 기준 시점복원 기능 구현이 완료 되었습니다.  
1. 이제 Script 구동으로 인한 백업시 YYYYmmdd_HHMMSS 형식으로 Directory를 생성하여 백업 시점을 구분합니다.  
2. Script 를 통한 Restore 수행시 시스템에 생성된 YYYYmmdd_HHMMSS 형식의 백업 Directory를 스캔하고, 확인된 백업 리스트를 사용자에게 알려줍니다.
3. 사용자가 입력한 복원시점을 기준으로 복구를 수행을 합니다.  
  
## [ 설명 ]
이 Script는 KISA 한국인터넷진흥원에서 배포/관리하는 UNIX/LINUX 계열 OS 취약점 진단/조치 가이드 72개 항목에 대한 진단 및 조치를 자동화 수행하는 Script 입니다.  
(https://www.kisa.or.kr/2060204/form?postSeq=12&lang_type=KO&page=1)  

1. 본 스크립트를 설치, 실행 함에 있어 발생 또는 발생 할 수 있는 모든 예기치 않은 오류나 손실에 대해서 본인은 법적인 책임을 갖지 않습니다.  
(단, 해당 스크립트의 사용 중 발생 또는 확인된 오류에 대해서 제보, 공유해 주시면 적극적으로 수정 및 반영토록 노력하겠습니다. helperchoi@gmail.com / Kwang Min Choi )
2. Redhat 계열( Centos, Rocky, RHEL, OEL 등 ) 7.x 이상, Ubuntu 18.04 LTS 이상 Systemd 기반 환경에서만 동작토록 구현되어있으며, 이미 EOL 된지 오래된 xinetd 기반 Linux 환경에서는 동작하지 않거나, 정상적인 실행이 어렵습니다.
3. 모든 처리 Logic은 각 기능별로 Function 화 구현되어 있어, 재사용, 분리, 실행 예외 처리 가능합니다.  
(공통 모듈 25개를 포함한 총 85개 이상 각 기능별로 분리된 Logic Function화)
![image](https://github.com/user-attachments/assets/74d4102e-ba6c-45eb-9a38-23a790499eb3)
  
4. **25년 4월 14일자 Script Version 1.0 이후 기준 72개 취약점 항목에 대해서 자동화 조치 구현 완료** (단 MW 진단항목 U35, U36, U37, U38, U39, U40, U41, U71 8개는 예외 처리중이며 추후 구현예정)  
5. 실제 Script 실행전 KISA Link 문서 확인을 통해 아래 예시와 같이 실행 환경 특성에 맞게 예외처리가 필요한 항목들을 반드시 확인 후 실행하는 것을 권장 합니다. 
  
(예 : k8s, docker 등 Container 환경에서 사용되는 OverlayFS 영역등에 적재되는 File 권한은 기본적으로 Container OS에 종속된 계정 UID/GID 값을 기준으로 생성되기 때문에 Woker Node등 Host OS에서는 소유주가 없는 파일로 인식됨.  
따라서 U-06 취약점 항목과 같은 소유주가 없는 파일에 대한 식별 및 삭제 조치를 취하는 항목의 실행에 대해서는 신중을 기해야하며, 본 Script에서도 U-06 취약항목에 대해서는 직접 파일 삭제를 하지 않고, 내역 표기 및 경고처리를 하도록 Logic화 구현 되어있음.)  
  
![image](https://github.com/user-attachments/assets/dc058820-49ac-413f-a789-d58f91e2121e)
  
![image](https://github.com/user-attachments/assets/ce4417ad-846d-4885-ae74-beca3d6eccd5)
  
4. 실행 예외가 필요한 항목이 확인되면, 아래 예시와 같이 Script 맨 하단부 FUNCT_MAIN_PROCESS 영역에서 대상 항목에 대해 간단히 주석처리를 통해 예외 처리 가능합니다.  
![image](https://github.com/user-attachments/assets/fa42e5ce-f87e-4363-8583-4538315d0a3d)

  
## [ 사용법 ]

1. 시스템에 root 로 Login 하거나 root 계정으로 스위칭을 수행 합니다. (ex : sudo -i)
2. 아래과 같은 명령을 통해 Script Download 및 설치를 수행 합니다.

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

[INFO] Script Download Path : /root/shell/KISA_SECURITY 
/root/shell/KISA_SECURITY/common
/root/shell/KISA_SECURITY/sec_std_conf.sh

[root@centos01 ~]# 
[root@centos01 ~]#
```
3. 아래와 같이 Script 실행시 실행 (PROC) / 복구 (RESTORE) 옵션을 선택 입력하여 실행을 수행하며 (진단 및 조치 자동화)  
취약점 조치 작업에 의한 시스템 이상 발생등, 유사시 작업전 형상으로 원복 및 복구를 위해 Script 실행시 기본적으로 관련 File 및 권한정보를 백업하도록 Logic화 되어있습니다.
```
[root@centos01 KISA_SECURITY]# 
[root@centos01 KISA_SECURITY]# ./sec_std_conf.sh 

[ERROR] centos01 WORK TYPE was not Input.

### 1. Input Work Type : Only PROC or RESTORE ###

Usage ) : ./sec_std_conf.sh PROC

[root@centos01 KISA_SECURITY]# 
[root@centos01 KISA_SECURITY]# 
[root@centos01 KISA_SECURITY]# 
[root@centos01 KISA_SECURITY]# ./sec_std_conf.sh PROC

[RECOMMEND] Be sure to read the guide document before running.
https://github.com/infra-se/system/blob/main/KISA_SECURITY/README.md

[QUESTION] Do you want run Script ? : y or n

y

### PROCESS U01 ###
[INFO] centos01 Backup Complete : /root/shell/CONF_BACKUP/etc/ssh/sshd_config.20250310_092633
[INFO] centos01 Processing PermitRootLogin no : /etc/ssh/sshd_config

### PROCESS U02 ###
[INFO] centos01 Backup Complete : /root/shell/CONF_BACKUP/etc/security/pwquality.conf.20250310_092633
[INFO] centos01 Processing Password Quality : /etc/security/pwquality.conf

### PROCESS U03 ###
[INFO] centos01 Backup Complete : /root/shell/CONF_BACKUP/etc/pam.d/system-auth.20250310_092633
[INFO] centos01 Processing Password Lock : /etc/pam.d/system-auth

### PROCESS U04 ###
[INFO] centos01 Shadow encryption enabled OK : /etc/shadow

### PROCESS U05 ###
[INFO] centos01 There is no problem with the PATH environment variable : OK

...  중략

[root@centos01 CONF_BACKUP]#
[root@centos01 CONF_BACKUP]# pwd
/root/shell/CONF_BACKUP
[root@centos01 CONF_BACKUP]#
[root@centos01 CONF_BACKUP]# ll
total 0
drwxr-xr-x 5 root root 46 Mar  5 15:00 etc
-rw-r--r-- 1 root root  0 Mar  5 15:00 NONE_USER_LIST
drwxr-xr-x 4 root root 28 Mar  5 15:00 permission
drwxr-xr-x 2 root root  6 Mar  5 15:00 service
[root@centos01 CONF_BACKUP]#
[root@centos01 CONF_BACKUP]# 
```

4. 필요시 아래와 같이 RESTORE 옵션 입력을 통해 SCRIPT 수행 전 형상으로 자동 원복/복구 가능 합니다.  
(2025.04.18. 반영된 버전 1.1 기준으로 시점복원 기능이 구현되어 있습니다. 원하는 복원 시점을 선택하여 입력하면 해당 시점으로 복원이 진행됩니다.)  
  
![image](https://github.com/user-attachments/assets/25b94059-7a88-49bc-9ac2-9313ccb46fd3)


