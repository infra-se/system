# [ Description ]
: Ansible YAML and Script below are used to automatically collect and manage infrastructure OS CI information.


## Key Functions:
FUNCT_CHECK_OS: Retrieves information about the operating system, including family, version, and kernel version.
FUNCT_CHECK_PLATFORM: Retrieves information about the platform, including vendor and product name.
FUNCT_CHECK_PERM: Retrieves information about file permissions, owner, and group.
FUNCT_CHECK_PACKAGE: Checks whether a specific package is installed.
FUNCT_NATIVE_DATE: Converts a Unix timestamp to a human-readable date format.
FUNCT_UNIX_DATE: Converts a human-readable date format to a Unix timestamp.
FUNCT_CI_COLLECT_01: Collects basic system information, such as CPU model, CPU count, memory size, disk space, and local IP addresses.
FUNCT_CI_COLLECT_02: Collects detailed information about mounted drives, including mount point, device name, file system type, size, type, used size, and daily cumulative usage.
FUNCT_CI_COLLECT_03: Collects information about user accounts, including username, UID, GID, home directory, and shell path.
FUNCT_CI_COLLECT_04: Collects information about running processes, including process ID, owner, and command.
FUNCT_CI_COLLECT_05: Collects information about network interfaces, including interface name, MAC address, IP address, type (master/slave/single), and link status.
FUNCT_CI_COLLECT_06: Collects information about active network sessions, including protocol, source port, destination port, session state, and process information.
FUNCT_CI_COLLECT_07: Checks for the presence of various software packages, including GCC, Java, glibc, and OpenSSL. It also retrieves their versions.


## [ Usage ]

1. Create Ansible Account or Login Ansible Account. (ex : su - helperchoi)
2. wget -O - https://github.com/infra-se/system/blob/main/ANSIBLE_SCRIPT/get_script.sh?raw=true | bash
3. cd ~/ANSIBLE_SCRIPT
4. Configure ansible.cfg or Delete ansible.cfg
```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ pwd
/home/helperchoi/ANSIBLE_SCRIPT
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ ls -l ansible.cfg 
-rwxr-x--- 1 helperchoi helperchoi 417 Nov 25 10:57 ansible.cfg
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ vi ansible.cfg

[helperchoi@centos01 ANSIBLE_SCRIPT]$
```
6. Open the ci_collect.sh, resources_collect.sh, and user_define_script.sh Scripts and modify the ANSIBLE_ACCOUNT and ANSIBLE_TARGET_GROUP variables to suit your environment.

```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ vi ci_collect.sh 
#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.3.20231212
ANSIBLE_ACCOUNT=helperchoi
ANSIBLE_TARGET_GROUP=TARGET_LIST

export LANG=C
export LC_ALL=C

```
7. Edit INVENTORY/work.hosts File
```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ vi INVENTORY/work.hosts 
[TARGET_LIST]
192.168.137.10
192.168.137.20
192.168.137.30
192.168.137.40
192.168.137.50 
```

8. Open check_ansible_env.sh and edit the ANSIBLE_ACCOUNT variable.
```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ vi check_ansible_env.sh 
#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.2.20231212

export LANG=C
export LC_ALL=C

ANSIBLE_ACCOUNT=helperchoi
ANSIBLE_TARGET_GROUP=TARGET_LIST

```

9. Execute the Ansible confirmation script as shown below.
```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ ./check_ansible_env.sh 

### Ansible Check OK - 4 ###
### Ansible Check FAIL - 1 ###
"msg": "Failed to connect to the host via ssh: ssh: connect to host 192.168.137.50 port 22: No route to host",

[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
```

10. Once the ansible environment check is complete, run the CI collection Main script as shown below.
```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ ./ci_collect.sh 

### 1. Edit Inventory File  : vi /home/helperchoi/ANSIBLE_SCRIPT/INVENTORY/work.hosts or prod.hosts ###
### 2. Select Group Name : WORK_LIST, PROD_LIST ###

Usage ex) : ./ci_collect.sh WORK_LIST or PROD_LIST

[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ ./ci_collect.sh WORK_LIST

### Run CI Collect Script ###

PLAY [TARGET_LIST] ******************************************************************************************************************************************

TASK [Check Script Dir - /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT : Progress 5%] ******************************************************************************
ok: [192.168.137.40]
ok: [192.168.137.50]
ok: [192.168.137.20]
ok: [192.168.137.10]
ok: [192.168.137.30]

TASK [Make Script Dir - /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT : Progress 10%] ******************************************************************************
skipping: [192.168.137.10]
changed: [192.168.137.40]
changed: [192.168.137.30]
changed: [192.168.137.50]
changed: [192.168.137.20]

TASK [Deploy CI Collect Script : Progress 15%] **************************************************************************************************************
changed: [192.168.137.40]
changed: [192.168.137.50]
changed: [192.168.137.20]
changed: [192.168.137.30]
changed: [192.168.137.10]

TASK [Run CI Script : Progress 20%] *************************************************************************************************************************
changed: [192.168.137.30]
changed: [192.168.137.40]
changed: [192.168.137.20]
changed: [192.168.137.50]
changed: [192.168.137.10]

TASK [Print Result : Progress 70%] **************************************************************************************************************************
ok: [192.168.137.10] => {
    "msg": [
        "[CHECK_RESULT] CI_SHEET_01|centos01|20230921|innotek GmbH|VirtualBox|CentOS|7.9|3.10.0-1160.el7.x86_64|Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz|2|0.967598|23.7695", 
        "[CHECK_RESULT] CI_SHEET_02|centos01|VirtualBox|/|555:root:root|/dev/mapper/centos_centos01-root|xfs|17.9824|part|3386|65|52.0923", 
        "[CHECK_RESULT] CI_SHEET_02|centos01|VirtualBox|/boot|555:root:root|/dev/sda1|xfs|0.990234|part|143|65|2.2", 
        "[CHECK_RESULT] CI_SHEET_02|centos01|VirtualBox|/nfs_vol|700:root:root|/dev/sdc|ext4|4.79688|disk|20|65|0.307692", 
        "[CHECK_RESULT] CI_SHEET_03|centos01|helperchoi|1000|1000|1000 10|/home/helperchoi|/bin/bash", 

...

        "[CHECK_RESULT] CI_SHEET_05|rhel01|VirtualBox|eth0|08:00:27:a0:0f:50|192.168.137.40/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_06|rhel01|tcp|0.0.0.0:*|0.0.0.0:22|LISTEN|1094/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|rhel01|tcp|0.0.0.0:*|127.0.0.1:25|LISTEN|1173/master", 
        "[CHECK_RESULT] CI_SHEET_06|rhel01|tcp|192.168.137.10:59230|192.168.137.40:22|ESTABLISHED|20000/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|rhel01|tcp|:::*|:::22|LISTEN|1094/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|rhel01|tcp|:::*|::1:25|LISTEN|1173/master", 
        "[CHECK_RESULT] CI_SHEET_07|rhel01|VirtualBox|Red Hat|6.10|N/A|N/A|2.12|1.0.1e"
    ]
}

PLAY RECAP **************************************************************************************************************************************************
192.168.137.10             : ok=4    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
192.168.137.20             : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.137.30             : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.137.40             : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.137.50             : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


### CREATE CI SHEET 01 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_01.log ###
[HOSTNAME]  [INSTALL_DATE]  [VENDOR]  [PLATFORM]  [OS_FAMILY]  [OS_VER]  [KER_VER]  [CPU_MODEL]  [CORE_COUNT]  [MEM_SIZE_GB]  [DISK_SUM_GB]
centos01  20230921  innotek GmbH  VirtualBox  CentOS   7.9   3.10.0-1160.el7.x86_64  Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz  2  0.967598  23.7695 
centos03  20231005  innotek GmbH  VirtualBox  CentOS   6.5   2.6.32-431.el6.x86_64   Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz  1  0.478954  23.5186 
centos02  20230921  innotek GmbH  VirtualBox  CentOS   7.9   3.10.0-1160.el7.x86_64  Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz  1  0.475574  30.5977 
rhel02    20231009  innotek GmbH  VirtualBox  Red Hat  7.9   3.10.0-1160.el7.x86_64  Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz  1  0.475574  17.9766 
rhel01    20231009  innotek GmbH  VirtualBox  Red Hat  6.10  2.6.32-754.el6.x86_64   Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz  1  0.478577  18.5889 


### CREATE CI SHEET 02 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_02.log ###
[HOSTNAME]  [PLATFORM]  [MOUNT_POINT]  [MOUNT_PERM]  [DISK_DEVCIE]  [FS_TYPE]  [DISK_SIZE_GB]  [DISK_TYPE]  [USED_SIZE_MB]  [CUMULATION_DATE]  [DAILY_CUMULATION]
centos01  VirtualBox  /            555:root:root  /dev/mapper/centos_centos01-root  xfs   17.9824   part  3386  65  52.0923 
centos01  VirtualBox  /boot        555:root:root  /dev/sda1                         xfs   0.990234  part  143   65  2.2 
centos01  VirtualBox  /nfs_vol     700:root:root  /dev/sdc                          ext4  4.79688   disk  20    65  0.307692 
centos03  VirtualBox  /            555:root:root  /dev/mapper/VolGroup-lv_root      ext4  18.248    rom   949   11  86.2727 
centos03  VirtualBox  /boot        555:root:root  /dev/sda1                         ext4  0.473633  part  33    11  3 
centos03  VirtualBox  /NAS         700:root:root  192.168.137.10:nfs_vol            nfs   4.79688   nas   20    11  1.81818 
centos02  VirtualBox  /            555:root:root  /dev/mapper/centos_centos01-root  xfs   17.9824   part  2983  25  119.32 
centos02  VirtualBox  /boot        555:root:root  /dev/sda1                         xfs   0.990234  part  143   25  5.72 
centos02  VirtualBox  /nvme_disk   755:root:root  /dev/nvme0n1                      ext4  1.90625   disk  6     25  0.24 
centos02  VirtualBox  /ISCSI_DISK  755:root:root  /dev/sdd                          ext4  9.71875   disk  37    25  1.48 
rhel02    VirtualBox  /            555:root:root  /dev/mapper/rhel-root             xfs   16.9863   part  2223  6   370.5 
rhel02    VirtualBox  /boot        555:root:root  /dev/sda1                         xfs   0.990234  part  142   6   23.6667 
rhel01    VirtualBox  /            555:root:root  /dev/mapper/VolGroup-lv_root      ext4  18.123    rom   824   5   164.8 
rhel01    VirtualBox  /boot        555:root:root  /dev/sda1                         ext4  0.46582   part  33    5   6.6 


### CREATE CI SHEET 03 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_03.log ###
[HOSTNAME]  [ACCOUNT]  [UID]  [GID]  [GIDs]  [Home  DIR]  [ANSIBLE_SCRIPT]
centos01  helperchoi  1000  1000  1000 10  /home/helperchoi  /bin/bash 
centos01  helperchoi      1001  1001  1001     /home/helperchoi      /bin/bash 
centos01  helperchoi      1002  1002  1002     /home/helperchoi      /bin/bash 
centos01  helperchoi-sec  4001  4001  4001     /home/helperchoi-sec  /bin/bash 
centos03  helperchoi      500   500   500      /home/helperchoi      /bin/bash 
centos02  helperchoi  1000  1000  1000 10  /home/helperchoi  /bin/bash 
centos02  helperchoi      1001  1001  1001     /home/helperchoi      /bin/bash 
centos02  helperchoi      1002  1002  1002 10  /home/helperchoi      /bin/bash 
rhel02    helperchoi      1000  1000  1000 10  /home/helperchoi      /bin/bash 
rhel01    helperchoi      500   500   500      /home/helperchoi      /bin/bash 


### CREATE CI SHEET 04 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_04.log ###
[HOSTNAME]  [PROCESS_OWNER]  [PROCESS_CMD]
centos01  root            /usr/lib/systemd/systemd --switched-root --system --deserialize 22  
centos01  root            [kthreadd]  
centos01  root            [kworker/0:0H]  

...

rhel01    postfix         pickup -l -t fifo -u  
rhel01    root            sshd: helperchoi [priv]  
rhel01    helperchoi          sshd: helperchoi@pts/0  
rhel01    root            /bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh  


### CREATE CI SHEET 05 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_05.log ###
[HOSTNAME]  [PLATFORM]  [ETH_NAME]  [MAC_ADDR]  [NW_INFO]  [ETH_TYPE]  [LINK_STAT]
centos01  VirtualBox  enp0s3  08:00:27:3e:f2:47  192.168.137.10/24   SINGLE  UP 
centos01  VirtualBox  enp0s8  08:00:27:05:fa:5e  192.168.100.100/24  SINGLE  UP 
centos03  VirtualBox  eth0    08:00:27:c2:73:3e  192.168.137.30/24   SINGLE  UP 
centos02  VirtualBox  enp0s3  08:00:27:25:7c:3e  192.168.137.99/24   SINGLE  UP 
centos02  VirtualBox  enp0s8  08:00:27:70:80:d5  192.168.100.110/24  SINGLE  UP 
rhel02    VirtualBox  enp0s3  08:00:27:1b:5f:4a  192.168.137.50/24   SINGLE  UP 
rhel01    VirtualBox  eth0    08:00:27:a0:0f:50  192.168.137.40/24   SINGLE  UP 


### CREATE CI SHEET 06 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_06.log ###
[HOSTNAME]  [PROTOCAL]  [SOURCE]  [DESTINATION]  [SESSION_STAT]  [PROCESS_INFO]
centos01  tcp   0.0.0.0:*              0.0.0.0:111            LISTEN       858/rpcbind 
centos01  tcp   0.0.0.0:*              0.0.0.0:20048          LISTEN       1223/rpc.mountd 
centos01  tcp   0.0.0.0:*              0.0.0.0:44306          LISTEN       - 
centos01  tcp   0.0.0.0:*              127.0.0.1:53           LISTEN       9926/named 
centos01  tcp   0.0.0.0:*              0.0.0.0:22             LISTEN       1612/sshd 

...

rhel02    tcp   192.168.137.10:41724   192.168.137.50:22      ESTABLISHED  19891/sshd: 
rhel02    tcp6  :::*                   :::22                  LISTEN       1051/sshd 
rhel02    tcp6  :::*                   ::1:25                 LISTEN       1310/master 
rhel02    tcp6  :::*                   :::111                 LISTEN       785/rpcbind 
rhel01    tcp   0.0.0.0:*              0.0.0.0:22             LISTEN       1094/sshd 
rhel01    tcp   0.0.0.0:*              127.0.0.1:25           LISTEN       1173/master 
rhel01    tcp   192.168.137.10:59230   192.168.137.40:22      ESTABLISHED  20000/sshd 
rhel01    tcp   :::*                   :::22                  LISTEN       1094/sshd 
rhel01    tcp   :::*                   ::1:25                 LISTEN       1173/master 


### CREATE CI SHEET 07 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_07.log ###
[HOSTNAME]  [PLATFORM]  [OS_FAMILY]  [OS_VER]  [ENABLE_JDK]  [GCC_VER]  [GLIBC_VER]  [OPENSSL_VER]
centos01  VirtualBox  CentOS   7.9   1.8.0.262.b10  4.8.5  2.17  1.0.2k
centos03  VirtualBox  CentOS   6.5   N/A            N/A    2.12  1.0.1e
centos02  VirtualBox  CentOS   7.9   1.8.0_262      4.8.5  2.17  1.0.2k
rhel02    VirtualBox  Red Hat  7.9   1.7.0.261      4.8.5  2.17  1.0.2k
rhel01    VirtualBox  Red Hat  6.10  N/A            N/A    2.12  1.0.1e

[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
```

## [ END ]
