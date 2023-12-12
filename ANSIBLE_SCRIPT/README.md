# This Directory is Ansible Script Top Path.
[ Usage ]

1. Create Ansible Account or Login Ansible Account. (ex : su - helperchoi)
2. wget -O - https://github.com/infra-se/system/blob/main/ANSIBLE_SCRIPT/get_script.sh?raw=true | bash
3. cd ~/ANSIBLE_SCRIPT
4. Configure ansible.cfg or Delete ansible.cfg
5. Open the ci_collect.sh, resources_collect.sh, and user_define_script.sh Scripts and modify the ANSIBLE_ACCOUNT and ANSIBLE_TARGET_GROUP variables to suit your environment.

```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ vi ci_collect.sh 
#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.3.20231212
ANSIBLE_ACCOUNT=ansadm
ANSIBLE_TARGET_GROUP=TARGET_LIST

export LANG=C
export LC_ALL=C

```
6. Edit INVENTORY/work.hosts File
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

7. Open check_ansible_env.sh and edit the ANSIBLE_ACCOUNT variable.
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

8. Execute the Ansible confirmation script as shown below.
```
[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
[helperchoi@centos01 ANSIBLE_SCRIPT]$ ./check_ansible_env.sh 

### Ansible Check OK - 4 ###
### Ansible Check FAIL - 1 ###
"msg": "Failed to connect to the host via ssh: ssh: connect to host 192.168.137.50 port 22: No route to host",

[helperchoi@centos01 ANSIBLE_SCRIPT]$ 
```

9. Once the ansible environment check is complete, run the CI collection Main script as shown below.
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
        "[CHECK_RESULT] CI_SHEET_03|centos01|ansadm|1001|1001|1001|/home/ansadm|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_03|centos01|helperchoi|1002|1002|1002|/home/helperchoi|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_03|centos01|ansadm-sec|4001|4001|4001|/home/ansadm-sec|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/lib/systemd/systemd --switched-root --system --deserialize 22 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kthreadd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/0:0H] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ksoftirqd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[migration/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[rcu_bh] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[rcu_sched] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[lru-add-drain] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[watchdog/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[watchdog/1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[migration/1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ksoftirqd/1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/1:0H] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kdevtmpfs] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[netns] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[khungtaskd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[writeback] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kintegrityd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kblockd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[md] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[edac-poller] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[watchdogd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kswapd0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ksmd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[khugepaged] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[crypto] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kthrotld] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kmpath_rdacd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kaluad] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ipv6_addrconf] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[deferwq] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kauditd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ata_sff] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_eh_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_tmf_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_eh_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_tmf_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_eh_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_tmf_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_eh_3] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_tmf_3] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_eh_4] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[scsi_tmf_4] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[irq/18-vmwgfx] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ttm_swap] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/0:1H] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/1:1H] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfsalloc] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs_mru_cache] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-buf/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-data/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-conv/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-cil/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-reclaim/dm-] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-log/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-eofblocks/d] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfsaild/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/lib/systemd/systemd-journald ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/lvmetad -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/lib/systemd/systemd-udevd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[rpciod] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xprtiod] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-buf/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-data/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-conv/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-cil/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-reclaim/sda] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-log/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfs-eofblocks/s] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xfsaild/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[jbd2/sdc-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[ext4-rsv-conver] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/sbin/auditd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/rpc.idmapd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|polkitd|/usr/lib/polkit-1/polkitd --no-debug ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|libstoragemgmt|/usr/bin/lsmd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/sbin/rngd -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|rpc|/sbin/rpcbind -w ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|dbus|/usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/gssproxy -D ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/abrtd -d -s ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/irqbalance --foreground ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/lib/systemd/systemd-logind ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/smartd -n -q never ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/NetworkManager --no-daemon ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/mcelog --ignorenodev --daemon --syslog ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|ntp|/usr/sbin/ntpd -u ntp:ntp -g ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/ntpd -u ntp:ntp -g ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/bin/python2 -Es /usr/sbin/tuned -l -P ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/rsyslogd -n ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|rpcuser|/usr/sbin/rpc.statd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/atd -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/crond -n ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/rpc.mountd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[target_completi] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[tmr-rd_mcp] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[xcopy_wq] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd4_callbacks] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[lockd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[nfsd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[tmr-iblock] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[iscsi_np] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/libexec/postfix/master -w ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|postfix|qmgr -l -t unix -u ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/sshd -D ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|named|/usr/sbin/named -u named -c /etc/named.conf ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/u4:2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|sshd: root@pts/0 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/u4:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/1:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|sshd: root@pts/1 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|postfix|pickup -l -t unix -u ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/0:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|su - helperchoi ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/0:2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/1:1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[iscsi_ttx] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[iscsi_trx] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/0:1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/1:2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|helperchoi|/bin/bash ./ci_collect.sh WORK_LIST ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|sshd: helperchoi [priv] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|helperchoi|sshd: helperchoi@pts/7 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|[kworker/0:3] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/sbin/agetty --noclear tty1 linux ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/sbin/httpd -DFOREGROUND ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|root|/usr/libexec/nss_pcache 4 off ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|apache|/usr/sbin/httpd -DFOREGROUND ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|apache|/usr/sbin/httpd -DFOREGROUND ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|apache|/usr/sbin/httpd -DFOREGROUND ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|apache|/usr/sbin/httpd -DFOREGROUND ", 
        "[CHECK_RESULT] CI_SHEET_04|centos01|apache|/usr/sbin/httpd -DFOREGROUND ", 
        "[CHECK_RESULT] CI_SHEET_05|centos01|VirtualBox|enp0s3|08:00:27:3e:f2:47|192.168.137.10/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_05|centos01|VirtualBox|enp0s8|08:00:27:05:fa:5e|192.168.100.100/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:111|LISTEN|858/rpcbind", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:20048|LISTEN|1223/rpc.mountd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:44306|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|127.0.0.1:53|LISTEN|9926/named", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:22|LISTEN|1612/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:46198|LISTEN|1177/rpc.statd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|127.0.0.1:953|LISTEN|9926/named", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|127.0.0.1:25|LISTEN|1495/master", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:3260|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|0.0.0.0:*|0.0.0.0:2049|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.30:58589|192.168.137.10:749|ESTABLISHED|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.10:22|192.168.137.10:42314|ESTABLISHED|23597/ssh:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.30:22|192.168.137.10:55364|ESTABLISHED|23820/ssh:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.1:56876|192.168.137.10:22|ESTABLISHED|20472/sshd:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.40:22|192.168.137.10:59230|ESTABLISHED|23604/ssh:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.50:22|192.168.137.10:41724|ESTABLISHED|23616/ssh:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.20:22|192.168.137.10:50762|ESTABLISHED|23601/ssh:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.10:42314|192.168.137.10:22|ESTABLISHED|23589/sshd:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.100.110:56000|192.168.100.100:3260|ESTABLISHED|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.1:60823|192.168.137.10:22|ESTABLISHED|21974/sshd:", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp|192.168.137.30:770|192.168.137.10:2049|ESTABLISHED|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::111|LISTEN|858/rpcbind", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::80|LISTEN|26668/httpd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::20048|LISTEN|1223/rpc.mountd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|::1:53|LISTEN|9926/named", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::22|LISTEN|1612/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|::1:953|LISTEN|9926/named", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|::1:25|LISTEN|1495/master", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::44665|LISTEN|1177/rpc.statd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::8443|LISTEN|26668/httpd", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::38272|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos01|tcp6|:::*|:::2049|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_07|centos01|VirtualBox|CentOS|7.9|1.8.0.262.b10|4.8.5|2.17|1.0.2k"
    ]
}
ok: [192.168.137.30] => {
    "msg": [
        "[CHECK_RESULT] CI_SHEET_01|centos03|20231005|innotek GmbH|VirtualBox|CentOS|6.5|2.6.32-431.el6.x86_64|Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz|1|0.478954|23.5186", 
        "[CHECK_RESULT] CI_SHEET_02|centos03|VirtualBox|/|555:root:root|/dev/mapper/VolGroup-lv_root|ext4|18.248|rom|949|11|86.2727", 
        "[CHECK_RESULT] CI_SHEET_02|centos03|VirtualBox|/boot|555:root:root|/dev/sda1|ext4|0.473633|part|33|11|3", 
        "[CHECK_RESULT] CI_SHEET_02|centos03|VirtualBox|/NAS|700:root:root|192.168.137.10:nfs_vol|nfs|4.79688|nas|20|11|1.81818", 
        "[CHECK_RESULT] CI_SHEET_03|centos03|helperchoi|500|500|500|/home/helperchoi|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/init ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kthreadd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[migration/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ksoftirqd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[migration/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[watchdog/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[events/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[cgroup] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[khelper] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[netns] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[async/mgr] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[pm] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[sync_supers] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[bdi-default] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kintegrityd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kblockd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kacpid] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kacpi_notify] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kacpi_hotplug] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ata_aux] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ata_sff/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ksuspend_usbd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[khubd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kseriod] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[md/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[md_misc/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[linkwatch] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[khungtaskd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kswapd0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ksmd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[aio/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[crypto/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kthrotld/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[usbhid_resumer] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kstriped] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[scsi_eh_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[scsi_eh_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[scsi_eh_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[jbd2/dm-0-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ext4-dio-unwrit] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/udevd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[jbd2/sda1-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[ext4-dio-unwrit] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[flush-253:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kauditd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|auditd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/rsyslogd -i /var/run/syslogd.pid -c 5 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/usr/sbin/sshd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/usr/libexec/postfix/master ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|postfix|qmgr -l -t fifo -u ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|crond ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/usr/sbin/atd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|login -- root ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/mingetty /dev/tty2 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/mingetty /dev/tty3 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/mingetty /dev/tty4 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/mingetty /dev/tty5 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/mingetty /dev/tty6 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/udevd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/sbin/udevd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[rpciod/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kslowd000] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[kslowd001] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[nfsiod] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|[nfsv4.0-svc] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|postfix|pickup -l -t fifo -u ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|sshd: helperchoi [priv] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|helperchoi|sshd: helperchoi@pts/0 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos03|root|/bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh ", 
        "[CHECK_RESULT] CI_SHEET_05|centos03|VirtualBox|eth0|08:00:27:c2:73:3e|192.168.137.30/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|0.0.0.0:*|0.0.0.0:22|LISTEN|836/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|0.0.0.0:*|127.0.0.1:25|LISTEN|913/master", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|0.0.0.0:*|0.0.0.0:58589|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|192.168.137.10:55364|192.168.137.30:22|ESTABLISHED|26866/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|192.168.137.10:2049|192.168.137.30:770|ESTABLISHED|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|192.168.137.10:749|192.168.137.30:58589|ESTABLISHED|-", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|:::*|:::22|LISTEN|836/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|:::*|::1:25|LISTEN|913/master", 
        "[CHECK_RESULT] CI_SHEET_06|centos03|tcp|:::*|:::35835|LISTEN|-", 
        "[CHECK_RESULT] CI_SHEET_07|centos03|VirtualBox|CentOS|6.5|N/A|N/A|2.12|1.0.1e"
    ]
}
ok: [192.168.137.20] => {
    "msg": [
        "[CHECK_RESULT] CI_SHEET_01|centos02|20230921|innotek GmbH|VirtualBox|CentOS|7.9|3.10.0-1160.el7.x86_64|Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz|1|0.475574|30.5977", 
        "[CHECK_RESULT] CI_SHEET_02|centos02|VirtualBox|/|555:root:root|/dev/mapper/centos_centos01-root|xfs|17.9824|part|2983|25|119.32", 
        "[CHECK_RESULT] CI_SHEET_02|centos02|VirtualBox|/boot|555:root:root|/dev/sda1|xfs|0.990234|part|143|25|5.72", 
        "[CHECK_RESULT] CI_SHEET_02|centos02|VirtualBox|/nvme_disk|755:root:root|/dev/nvme0n1|ext4|1.90625|disk|6|25|0.24", 
        "[CHECK_RESULT] CI_SHEET_02|centos02|VirtualBox|/ISCSI_DISK|755:root:root|/dev/sdd|ext4|9.71875|disk|37|25|1.48", 
        "[CHECK_RESULT] CI_SHEET_03|centos02|helperchoi|1000|1000|1000 10|/home/helperchoi|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_03|centos02|ansadm|1001|1001|1001|/home/ansadm|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_03|centos02|helperchoi|1002|1002|1002 10|/home/helperchoi|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/lib/systemd/systemd --switched-root --system --deserialize 22 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kthreadd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/0:0H] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ksoftirqd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[migration/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[rcu_bh] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[rcu_sched] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[lru-add-drain] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[watchdog/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kdevtmpfs] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[netns] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[khungtaskd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[writeback] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kintegrityd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kblockd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[md] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[edac-poller] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[watchdogd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kswapd0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ksmd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[crypto] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kthrotld] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kmpath_rdacd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kaluad] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ipv6_addrconf] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[deferwq] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kauditd] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ata_sff] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_eh_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_tmf_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_eh_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_tmf_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_eh_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_tmf_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[irq/18-vmwgfx] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ttm_swap] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/0:1H] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfsalloc] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs_mru_cache] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-buf/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-data/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-conv/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-cil/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-reclaim/dm-] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-log/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-eofblocks/d] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfsaild/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/lib/systemd/systemd-journald ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/lvmetad -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/lib/systemd/systemd-udevd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[nvme-wq] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[nvme-reset-wq] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[nvme-delete-wq] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[mpt_poll_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[mpt/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_eh_3] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_tmf_3] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[mpt_poll_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[mpt/1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_eh_4] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_tmf_4] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-buf/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-data/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-conv/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-cil/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-reclaim/sda] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-log/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfs-eofblocks/s] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xfsaild/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/sbin/auditd ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[rpciod] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[xprtiod] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|libstoragemgmt|/usr/bin/lsmd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|polkitd|/usr/lib/polkit-1/polkitd --no-debug ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/smartd -n -q never ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/abrtd -d -s ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/lib/systemd/systemd-logind ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|dbus|/usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/gssproxy -D ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/sbin/rngd -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|rpc|/sbin/rpcbind -w ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/mcelog --ignorenodev --daemon --syslog ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/NetworkManager --no-daemon ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/bin/python2 -Es /usr/sbin/tuned -l -P ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/sshd -D ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|tomcat|/usr/lib/jvm/jre/bin/java -Djavax.sql.DataSource.Factory=org.apache.commons.dbcp.BasicDataSourceFactory -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr/share/java/commons-daemon.jar -Dcatalina.base=/usr/share/tomcat -Dcatalina.home=/usr/share/tomcat ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/rsyslogd -n ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/sbin/iscsid -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[iscsi_eh] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_eh_5] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_tmf_5] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[iscsi_q_5] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[scsi_wq_5] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/atd -f ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/sbin/crond -n ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|login -- root ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/usr/libexec/postfix/master -w ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|postfix|qmgr -l -t unix -u ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[jbd2/nvme0n1-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ext4-rsv-conver] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[jbd2/sdd-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[ext4-rsv-conver] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/u2:1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|postfix|pickup -l -t unix -u ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/u2:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/0:1] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/0:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|sshd: helperchoi [priv] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|helperchoi|sshd: helperchoi@pts/0 ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|[kworker/0:2] ", 
        "[CHECK_RESULT] CI_SHEET_04|centos02|root|/bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh ", 
        "[CHECK_RESULT] CI_SHEET_05|centos02|VirtualBox|enp0s3|08:00:27:25:7c:3e|192.168.137.99/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_05|centos02|VirtualBox|enp0s8|08:00:27:70:80:d5|192.168.100.110/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp|0.0.0.0:*|0.0.0.0:111|LISTEN|868/rpcbind", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp|0.0.0.0:*|0.0.0.0:22|LISTEN|1282/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp|0.0.0.0:*|127.0.0.1:25|LISTEN|1586/master", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp|192.168.137.10:50762|192.168.137.20:22|ESTABLISHED|15815/sshd:", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp|192.168.100.100:3260|192.168.100.110:56000|ESTABLISHED|1291/iscsid", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp6|:::*|127.0.0.1:8005|LISTEN|1284/java", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp6|:::*|:::8009|LISTEN|1284/java", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp6|:::*|:::111|LISTEN|868/rpcbind", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp6|:::*|:::8080|LISTEN|1284/java", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp6|:::*|:::22|LISTEN|1282/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|centos02|tcp6|:::*|::1:25|LISTEN|1586/master", 
        "[CHECK_RESULT] CI_SHEET_07|centos02|VirtualBox|CentOS|7.9|1.8.0_262|4.8.5|2.17|1.0.2k"
    ]
}
ok: [192.168.137.50] => {
    "msg": [
        "[CHECK_RESULT] CI_SHEET_01|rhel02|20231009|innotek GmbH|VirtualBox|Red Hat|7.9|3.10.0-1160.el7.x86_64|Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz|1|0.475574|17.9766", 
        "[CHECK_RESULT] CI_SHEET_02|rhel02|VirtualBox|/|555:root:root|/dev/mapper/rhel-root|xfs|16.9863|part|2223|6|370.5", 
        "[CHECK_RESULT] CI_SHEET_02|rhel02|VirtualBox|/boot|555:root:root|/dev/sda1|xfs|0.990234|part|142|6|23.6667", 
        "[CHECK_RESULT] CI_SHEET_03|rhel02|helperchoi|1000|1000|1000 10|/home/helperchoi|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/lib/systemd/systemd --switched-root --system --deserialize 22 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kthreadd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/0:0H] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[ksoftirqd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[migration/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[rcu_bh] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[rcu_sched] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[lru-add-drain] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[watchdog/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kdevtmpfs] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[netns] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[khungtaskd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[writeback] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kintegrityd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kblockd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[md] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[edac-poller] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[watchdogd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kswapd0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[ksmd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[crypto] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kthrotld] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kmpath_rdacd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kaluad] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[ipv6_addrconf] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[deferwq] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kauditd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[ata_sff] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[scsi_eh_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[scsi_tmf_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[scsi_eh_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[scsi_tmf_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[scsi_eh_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/u2:3] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[scsi_tmf_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[irq/18-vmwgfx] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[ttm_swap] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[bioset] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfsalloc] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs_mru_cache] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-buf/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-data/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-conv/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-cil/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-reclaim/dm-] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-log/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-eofblocks/d] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfsaild/dm-0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/0:1H] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/lib/systemd/systemd-journald ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/lvmetad -f ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/lib/systemd/systemd-udevd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-buf/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-data/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-conv/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-cil/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-reclaim/sda] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-log/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfs-eofblocks/s] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xfsaild/sda1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/sbin/auditd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[rpciod] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[xprtiod] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/abrtd -d -s ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/sbin/rngd -f ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|rpc|/sbin/rpcbind -w ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/smartd -n -q never ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|libstoragemgmt|/usr/bin/lsmd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/gssproxy -D ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|polkitd|/usr/lib/polkit-1/polkitd --no-debug ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/lib/systemd/systemd-logind ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|dbus|/usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/NetworkManager --no-daemon ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/bin/rhsmcertd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/sshd -D ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/bin/python2 -Es /usr/sbin/tuned -l -P ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/rsyslogd -n ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/atd -f ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/sbin/crond -n ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|login -- root ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|rhnsd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/usr/libexec/postfix/master -w ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|postfix|qmgr -l -t unix -u ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/u2:1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|postfix|pickup -l -t unix -u ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/0:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/0:2] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/0:1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|[kworker/0:3] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|sshd: helperchoi [priv] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|helperchoi|sshd: helperchoi@pts/0 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel02|root|/bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh ", 
        "[CHECK_RESULT] CI_SHEET_05|rhel02|VirtualBox|enp0s3|08:00:27:1b:5f:4a|192.168.137.50/24|SINGLE|UP", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp|0.0.0.0:*|0.0.0.0:22|LISTEN|1051/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp|0.0.0.0:*|127.0.0.1:25|LISTEN|1310/master", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp|0.0.0.0:*|0.0.0.0:111|LISTEN|785/rpcbind", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp|192.168.137.10:41724|192.168.137.50:22|ESTABLISHED|19891/sshd:", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp6|:::*|:::22|LISTEN|1051/sshd", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp6|:::*|::1:25|LISTEN|1310/master", 
        "[CHECK_RESULT] CI_SHEET_06|rhel02|tcp6|:::*|:::111|LISTEN|785/rpcbind", 
        "[CHECK_RESULT] CI_SHEET_07|rhel02|VirtualBox|Red Hat|7.9|1.7.0.261|4.8.5|2.17|1.0.2k"
    ]
}
ok: [192.168.137.40] => {
    "msg": [
        "[CHECK_RESULT] CI_SHEET_01|rhel01|20231009|innotek GmbH|VirtualBox|Red Hat|6.10|2.6.32-754.el6.x86_64|Intel(R) Core(TM) i7-4500U CPU @ 1.80GHz|1|0.478577|18.5889", 
        "[CHECK_RESULT] CI_SHEET_02|rhel01|VirtualBox|/|555:root:root|/dev/mapper/VolGroup-lv_root|ext4|18.123|rom|824|5|164.8", 
        "[CHECK_RESULT] CI_SHEET_02|rhel01|VirtualBox|/boot|555:root:root|/dev/sda1|ext4|0.46582|part|33|5|6.6", 
        "[CHECK_RESULT] CI_SHEET_03|rhel01|helperchoi|500|500|500|/home/helperchoi|/bin/bash", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/init ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kthreadd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[migration/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ksoftirqd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[stopper/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[watchdog/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[events/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[events/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[events_long/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[events_power_ef] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[cgroup] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[khelper] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[netns] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[async/mgr] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[pm] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[sync_supers] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[bdi-default] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kintegrityd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kblockd/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kacpid] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kacpi_notify] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kacpi_hotplug] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ata_aux] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ata_sff/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ksuspend_usbd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[khubd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kseriod] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[md/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[md_misc/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[linkwatch] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[khungtaskd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[lru-add-drain/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kswapd0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ksmd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[aio/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[crypto/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kthrotld/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[usbhid_resumer] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[deferwq] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kdmremove] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kstriped] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ttm_swap] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[scsi_eh_0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[scsi_eh_1] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[scsi_eh_2] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kdmflush] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[jbd2/dm-0-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ext4-dio-unwrit] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/udevd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/udevd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/udevd -d ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[jbd2/sda1-8] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ext4-dio-unwrit] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[kauditd] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ib_addr] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[infiniband/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ib_mcast] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[iw_cm_wq] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ib_cm/0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[rdma_cm] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[ipoib_flush] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|[flush-253:0] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|auditd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/rsyslogd -i /var/run/syslogd.pid -c 5 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/usr/sbin/sshd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/usr/libexec/postfix/master ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|crond ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|postfix|qmgr -l -t fifo -u ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/usr/bin/rhsmcertd ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|login -- root ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/mingetty /dev/tty2 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/mingetty /dev/tty3 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/mingetty /dev/tty4 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/mingetty /dev/tty5 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/sbin/mingetty /dev/tty6 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|postfix|pickup -l -t fifo -u ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|sshd: helperchoi [priv] ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|helperchoi|sshd: helperchoi@pts/0 ", 
        "[CHECK_RESULT] CI_SHEET_04|rhel01|root|/bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh ", 
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
centos01  ansadm      1001  1001  1001     /home/ansadm      /bin/bash 
centos01  helperchoi      1002  1002  1002     /home/helperchoi      /bin/bash 
centos01  ansadm-sec  4001  4001  4001     /home/ansadm-sec  /bin/bash 
centos03  helperchoi      500   500   500      /home/helperchoi      /bin/bash 
centos02  helperchoi  1000  1000  1000 10  /home/helperchoi  /bin/bash 
centos02  ansadm      1001  1001  1001     /home/ansadm      /bin/bash 
centos02  helperchoi      1002  1002  1002 10  /home/helperchoi      /bin/bash 
rhel02    helperchoi      1000  1000  1000 10  /home/helperchoi      /bin/bash 
rhel01    helperchoi      500   500   500      /home/helperchoi      /bin/bash 


### CREATE CI SHEET 04 - /home/helperchoi/ANSIBLE_SCRIPT/CI_RESULT/ci_04.log ###
[HOSTNAME]  [PROCESS_OWNER]  [PROCESS_CMD]
centos01  root            /usr/lib/systemd/systemd --switched-root --system --deserialize 22  
centos01  root            [kthreadd]  
centos01  root            [kworker/0:0H]  
centos01  root            [ksoftirqd/0]  
centos01  root            [migration/0]  
centos01  root            [rcu_bh]  
centos01  root            [rcu_sched]  
centos01  root            [lru-add-drain]  
centos01  root            [watchdog/0]  
centos01  root            [watchdog/1]  
centos01  root            [migration/1]  
centos01  root            [ksoftirqd/1]  
centos01  root            [kworker/1:0H]  
centos01  root            [kdevtmpfs]  
centos01  root            [netns]  
centos01  root            [khungtaskd]  
centos01  root            [writeback]  
centos01  root            [kintegrityd]  
centos01  root            [bioset]  
centos01  root            [bioset]  
centos01  root            [bioset]  
centos01  root            [kblockd]  
centos01  root            [md]  
centos01  root            [edac-poller]  
centos01  root            [watchdogd]  
centos01  root            [kswapd0]  
centos01  root            [ksmd]  
centos01  root            [khugepaged]  
centos01  root            [crypto]  
centos01  root            [kthrotld]  
centos01  root            [kmpath_rdacd]  
centos01  root            [kaluad]  
centos01  root            [ipv6_addrconf]  
centos01  root            [deferwq]  
centos01  root            [kauditd]  
centos01  root            [ata_sff]  
centos01  root            [scsi_eh_0]  
centos01  root            [scsi_tmf_0]  
centos01  root            [scsi_eh_1]  
centos01  root            [scsi_tmf_1]  
centos01  root            [scsi_eh_2]  
centos01  root            [scsi_tmf_2]  
centos01  root            [scsi_eh_3]  
centos01  root            [scsi_tmf_3]  
centos01  root            [scsi_eh_4]  
centos01  root            [scsi_tmf_4]  
centos01  root            [irq/18-vmwgfx]  
centos01  root            [ttm_swap]  
centos01  root            [kworker/0:1H]  
centos01  root            [kworker/1:1H]  
centos01  root            [kdmflush]  
centos01  root            [bioset]  
centos01  root            [kdmflush]  
centos01  root            [bioset]  
centos01  root            [bioset]  
centos01  root            [xfsalloc]  
centos01  root            [xfs_mru_cache]  
centos01  root            [xfs-buf/dm-0]  
centos01  root            [xfs-data/dm-0]  
centos01  root            [xfs-conv/dm-0]  
centos01  root            [xfs-cil/dm-0]  
centos01  root            [xfs-reclaim/dm-]  
centos01  root            [xfs-log/dm-0]  
centos01  root            [xfs-eofblocks/d]  
centos01  root            [xfsaild/dm-0]  
centos01  root            /usr/lib/systemd/systemd-journald  
centos01  root            /usr/sbin/lvmetad -f  
centos01  root            /usr/lib/systemd/systemd-udevd  
centos01  root            [rpciod]  
centos01  root            [xprtiod]  
centos01  root            [xfs-buf/sda1]  
centos01  root            [xfs-data/sda1]  
centos01  root            [xfs-conv/sda1]  
centos01  root            [xfs-cil/sda1]  
centos01  root            [xfs-reclaim/sda]  
centos01  root            [xfs-log/sda1]  
centos01  root            [xfs-eofblocks/s]  
centos01  root            [xfsaild/sda1]  
centos01  root            [jbd2/sdc-8]  
centos01  root            [ext4-rsv-conver]  
centos01  root            /sbin/auditd  
centos01  root            /usr/sbin/rpc.idmapd  
centos01  polkitd         /usr/lib/polkit-1/polkitd --no-debug  
centos01  libstoragemgmt  /usr/bin/lsmd -d  
centos01  root            /sbin/rngd -f  
centos01  rpc             /sbin/rpcbind -w  
centos01  dbus            /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation  
centos01  root            /usr/sbin/gssproxy -D  
centos01  root            /usr/sbin/abrtd -d -s  
centos01  root            /usr/sbin/irqbalance --foreground  
centos01  root            /usr/lib/systemd/systemd-logind  
centos01  root            /usr/sbin/smartd -n -q never  
centos01  root            /usr/sbin/NetworkManager --no-daemon  
centos01  root            /usr/sbin/mcelog --ignorenodev --daemon --syslog  
centos01  ntp             /usr/sbin/ntpd -u ntp:ntp -g  
centos01  root            /usr/sbin/ntpd -u ntp:ntp -g  
centos01  root            /usr/bin/python2 -Es /usr/sbin/tuned -l -P  
centos01  root            /usr/sbin/rsyslogd -n  
centos01  rpcuser         /usr/sbin/rpc.statd  
centos01  root            /usr/sbin/atd -f  
centos01  root            /usr/sbin/crond -n  
centos01  root            /usr/sbin/rpc.mountd  
centos01  root            [target_completi]  
centos01  root            [tmr-rd_mcp]  
centos01  root            [xcopy_wq]  
centos01  root            [nfsd4_callbacks]  
centos01  root            [lockd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [nfsd]  
centos01  root            [bioset]  
centos01  root            [tmr-iblock]  
centos01  root            [iscsi_np]  
centos01  root            /usr/libexec/postfix/master -w  
centos01  postfix         qmgr -l -t unix -u  
centos01  root            /usr/sbin/sshd -D  
centos01  named           /usr/sbin/named -u named -c /etc/named.conf  
centos01  root            [kworker/u4:2]  
centos01  root            sshd: root@pts/0  
centos01  root            [kworker/u4:0]  
centos01  root            [kworker/1:0]  
centos01  root            sshd: root@pts/1  
centos01  postfix         pickup -l -t unix -u  
centos01  root            [kworker/0:0]  
centos01  root            su - helperchoi  
centos01  root            [kworker/0:2]  
centos01  root            [kworker/1:1]  
centos01  root            [iscsi_ttx]  
centos01  root            [iscsi_trx]  
centos01  root            [kworker/0:1]  
centos01  root            [kworker/1:2]  
centos01  helperchoi          /bin/bash ./ci_collect.sh WORK_LIST  
centos01  root            sshd: helperchoi [priv]  
centos01  helperchoi          sshd: helperchoi@pts/7  
centos01  root            [kworker/0:3]  
centos01  root            /bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh  
centos01  root            /sbin/agetty --noclear tty1 linux  
centos01  root            /usr/sbin/httpd -DFOREGROUND  
centos01  root            /usr/libexec/nss_pcache 4 off  
centos01  apache          /usr/sbin/httpd -DFOREGROUND  
centos01  apache          /usr/sbin/httpd -DFOREGROUND  
centos01  apache          /usr/sbin/httpd -DFOREGROUND  
centos01  apache          /usr/sbin/httpd -DFOREGROUND  
centos01  apache          /usr/sbin/httpd -DFOREGROUND  
centos03  root            /sbin/init  
centos03  root            [kthreadd]  
centos03  root            [migration/0]  
centos03  root            [ksoftirqd/0]  
centos03  root            [migration/0]  
centos03  root            [watchdog/0]  
centos03  root            [events/0]  
centos03  root            [cgroup]  
centos03  root            [khelper]  
centos03  root            [netns]  
centos03  root            [async/mgr]  
centos03  root            [pm]  
centos03  root            [sync_supers]  
centos03  root            [bdi-default]  
centos03  root            [kintegrityd/0]  
centos03  root            [kblockd/0]  
centos03  root            [kacpid]  
centos03  root            [kacpi_notify]  
centos03  root            [kacpi_hotplug]  
centos03  root            [ata_aux]  
centos03  root            [ata_sff/0]  
centos03  root            [ksuspend_usbd]  
centos03  root            [khubd]  
centos03  root            [kseriod]  
centos03  root            [md/0]  
centos03  root            [md_misc/0]  
centos03  root            [linkwatch]  
centos03  root            [khungtaskd]  
centos03  root            [kswapd0]  
centos03  root            [ksmd]  
centos03  root            [aio/0]  
centos03  root            [crypto/0]  
centos03  root            [kthrotld/0]  
centos03  root            [usbhid_resumer]  
centos03  root            [kstriped]  
centos03  root            [scsi_eh_0]  
centos03  root            [scsi_eh_1]  
centos03  root            [scsi_eh_2]  
centos03  root            [kdmflush]  
centos03  root            [kdmflush]  
centos03  root            [jbd2/dm-0-8]  
centos03  root            [ext4-dio-unwrit]  
centos03  root            /sbin/udevd -d  
centos03  root            [jbd2/sda1-8]  
centos03  root            [ext4-dio-unwrit]  
centos03  root            [flush-253:0]  
centos03  root            [kauditd]  
centos03  root            auditd  
centos03  root            /sbin/rsyslogd -i /var/run/syslogd.pid -c 5  
centos03  root            /usr/sbin/sshd  
centos03  root            /usr/libexec/postfix/master  
centos03  postfix         qmgr -l -t fifo -u  
centos03  root            crond  
centos03  root            /usr/sbin/atd  
centos03  root            login -- root  
centos03  root            /sbin/mingetty /dev/tty2  
centos03  root            /sbin/mingetty /dev/tty3  
centos03  root            /sbin/mingetty /dev/tty4  
centos03  root            /sbin/mingetty /dev/tty5  
centos03  root            /sbin/mingetty /dev/tty6  
centos03  root            /sbin/udevd -d  
centos03  root            /sbin/udevd -d  
centos03  root            [rpciod/0]  
centos03  root            [kslowd000]  
centos03  root            [kslowd001]  
centos03  root            [nfsiod]  
centos03  root            [nfsv4.0-svc]  
centos03  postfix         pickup -l -t fifo -u  
centos03  root            sshd: helperchoi [priv]  
centos03  helperchoi          sshd: helperchoi@pts/0  
centos03  root            /bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh  
centos02  root            /usr/lib/systemd/systemd --switched-root --system --deserialize 22  
centos02  root            [kthreadd]  
centos02  root            [kworker/0:0H]  
centos02  root            [ksoftirqd/0]  
centos02  root            [migration/0]  
centos02  root            [rcu_bh]  
centos02  root            [rcu_sched]  
centos02  root            [lru-add-drain]  
centos02  root            [watchdog/0]  
centos02  root            [kdevtmpfs]  
centos02  root            [netns]  
centos02  root            [khungtaskd]  
centos02  root            [writeback]  
centos02  root            [kintegrityd]  
centos02  root            [bioset]  
centos02  root            [bioset]  
centos02  root            [bioset]  
centos02  root            [kblockd]  
centos02  root            [md]  
centos02  root            [edac-poller]  
centos02  root            [watchdogd]  
centos02  root            [kswapd0]  
centos02  root            [ksmd]  
centos02  root            [crypto]  
centos02  root            [kthrotld]  
centos02  root            [kmpath_rdacd]  
centos02  root            [kaluad]  
centos02  root            [ipv6_addrconf]  
centos02  root            [deferwq]  
centos02  root            [kauditd]  
centos02  root            [ata_sff]  
centos02  root            [scsi_eh_0]  
centos02  root            [scsi_tmf_0]  
centos02  root            [scsi_eh_1]  
centos02  root            [scsi_tmf_1]  
centos02  root            [scsi_eh_2]  
centos02  root            [scsi_tmf_2]  
centos02  root            [irq/18-vmwgfx]  
centos02  root            [ttm_swap]  
centos02  root            [kworker/0:1H]  
centos02  root            [kdmflush]  
centos02  root            [bioset]  
centos02  root            [kdmflush]  
centos02  root            [bioset]  
centos02  root            [bioset]  
centos02  root            [xfsalloc]  
centos02  root            [xfs_mru_cache]  
centos02  root            [xfs-buf/dm-0]  
centos02  root            [xfs-data/dm-0]  
centos02  root            [xfs-conv/dm-0]  
centos02  root            [xfs-cil/dm-0]  
centos02  root            [xfs-reclaim/dm-]  
centos02  root            [xfs-log/dm-0]  
centos02  root            [xfs-eofblocks/d]  
centos02  root            [xfsaild/dm-0]  
centos02  root            /usr/lib/systemd/systemd-journald  
centos02  root            /usr/sbin/lvmetad -f  
centos02  root            /usr/lib/systemd/systemd-udevd  
centos02  root            [nvme-wq]  
centos02  root            [nvme-reset-wq]  
centos02  root            [nvme-delete-wq]  
centos02  root            [mpt_poll_0]  
centos02  root            [mpt/0]  
centos02  root            [scsi_eh_3]  
centos02  root            [scsi_tmf_3]  
centos02  root            [mpt_poll_1]  
centos02  root            [mpt/1]  
centos02  root            [scsi_eh_4]  
centos02  root            [scsi_tmf_4]  
centos02  root            [xfs-buf/sda1]  
centos02  root            [xfs-data/sda1]  
centos02  root            [xfs-conv/sda1]  
centos02  root            [xfs-cil/sda1]  
centos02  root            [xfs-reclaim/sda]  
centos02  root            [xfs-log/sda1]  
centos02  root            [xfs-eofblocks/s]  
centos02  root            [xfsaild/sda1]  
centos02  root            /sbin/auditd  
centos02  root            [rpciod]  
centos02  root            [xprtiod]  
centos02  libstoragemgmt  /usr/bin/lsmd -d  
centos02  polkitd         /usr/lib/polkit-1/polkitd --no-debug  
centos02  root            /usr/sbin/smartd -n -q never  
centos02  root            /usr/sbin/abrtd -d -s  
centos02  root            /usr/lib/systemd/systemd-logind  
centos02  dbus            /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation  
centos02  root            /usr/sbin/gssproxy -D  
centos02  root            /sbin/rngd -f  
centos02  rpc             /sbin/rpcbind -w  
centos02  root            /usr/sbin/mcelog --ignorenodev --daemon --syslog  
centos02  root            /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid  
centos02  root            /usr/sbin/NetworkManager --no-daemon  
centos02  root            /usr/bin/python2 -Es /usr/sbin/tuned -l -P  
centos02  root            /usr/sbin/sshd -D  
centos02  tomcat          /usr/lib/jvm/jre/bin/java -Djavax.sql.DataSource.Factory=org.apache.commons.dbcp.BasicDataSourceFactory -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr/share/java/commons-daemon.jar -Dcatalina.base=/usr/share/tomcat -Dcatalina.home=/usr/share/tomcat  
centos02  root            /usr/sbin/rsyslogd -n  
centos02  root            /sbin/iscsid -f  
centos02  root            [iscsi_eh]  
centos02  root            [scsi_eh_5]  
centos02  root            [scsi_tmf_5]  
centos02  root            [iscsi_q_5]  
centos02  root            [scsi_wq_5]  
centos02  root            /usr/sbin/atd -f  
centos02  root            /usr/sbin/crond -n  
centos02  root            login -- root  
centos02  root            /usr/libexec/postfix/master -w  
centos02  postfix         qmgr -l -t unix -u  
centos02  root            [jbd2/nvme0n1-8]  
centos02  root            [ext4-rsv-conver]  
centos02  root            [jbd2/sdd-8]  
centos02  root            [ext4-rsv-conver]  
centos02  root            [kworker/u2:1]  
centos02  postfix         pickup -l -t unix -u  
centos02  root            [kworker/u2:0]  
centos02  root            [kworker/0:1]  
centos02  root            [kworker/0:0]  
centos02  root            /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf  
centos02  root            sshd: helperchoi [priv]  
centos02  helperchoi          sshd: helperchoi@pts/0  
centos02  root            [kworker/0:2]  
centos02  root            /bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh  
rhel02    root            /usr/lib/systemd/systemd --switched-root --system --deserialize 22  
rhel02    root            [kthreadd]  
rhel02    root            [kworker/0:0H]  
rhel02    root            [ksoftirqd/0]  
rhel02    root            [migration/0]  
rhel02    root            [rcu_bh]  
rhel02    root            [rcu_sched]  
rhel02    root            [lru-add-drain]  
rhel02    root            [watchdog/0]  
rhel02    root            [kdevtmpfs]  
rhel02    root            [netns]  
rhel02    root            [khungtaskd]  
rhel02    root            [writeback]  
rhel02    root            [kintegrityd]  
rhel02    root            [bioset]  
rhel02    root            [bioset]  
rhel02    root            [bioset]  
rhel02    root            [kblockd]  
rhel02    root            [md]  
rhel02    root            [edac-poller]  
rhel02    root            [watchdogd]  
rhel02    root            [kswapd0]  
rhel02    root            [ksmd]  
rhel02    root            [crypto]  
rhel02    root            [kthrotld]  
rhel02    root            [kmpath_rdacd]  
rhel02    root            [kaluad]  
rhel02    root            [ipv6_addrconf]  
rhel02    root            [deferwq]  
rhel02    root            [kauditd]  
rhel02    root            [ata_sff]  
rhel02    root            [scsi_eh_0]  
rhel02    root            [scsi_tmf_0]  
rhel02    root            [scsi_eh_1]  
rhel02    root            [scsi_tmf_1]  
rhel02    root            [scsi_eh_2]  
rhel02    root            [kworker/u2:3]  
rhel02    root            [scsi_tmf_2]  
rhel02    root            [irq/18-vmwgfx]  
rhel02    root            [ttm_swap]  
rhel02    root            [kdmflush]  
rhel02    root            [bioset]  
rhel02    root            [kdmflush]  
rhel02    root            [bioset]  
rhel02    root            [bioset]  
rhel02    root            [xfsalloc]  
rhel02    root            [xfs_mru_cache]  
rhel02    root            [xfs-buf/dm-0]  
rhel02    root            [xfs-data/dm-0]  
rhel02    root            [xfs-conv/dm-0]  
rhel02    root            [xfs-cil/dm-0]  
rhel02    root            [xfs-reclaim/dm-]  
rhel02    root            [xfs-log/dm-0]  
rhel02    root            [xfs-eofblocks/d]  
rhel02    root            [xfsaild/dm-0]  
rhel02    root            [kworker/0:1H]  
rhel02    root            /usr/lib/systemd/systemd-journald  
rhel02    root            /usr/sbin/lvmetad -f  
rhel02    root            /usr/lib/systemd/systemd-udevd  
rhel02    root            [xfs-buf/sda1]  
rhel02    root            [xfs-data/sda1]  
rhel02    root            [xfs-conv/sda1]  
rhel02    root            [xfs-cil/sda1]  
rhel02    root            [xfs-reclaim/sda]  
rhel02    root            [xfs-log/sda1]  
rhel02    root            [xfs-eofblocks/s]  
rhel02    root            [xfsaild/sda1]  
rhel02    root            /sbin/auditd  
rhel02    root            [rpciod]  
rhel02    root            [xprtiod]  
rhel02    root            /usr/sbin/abrtd -d -s  
rhel02    root            /sbin/rngd -f  
rhel02    rpc             /sbin/rpcbind -w  
rhel02    root            /usr/sbin/smartd -n -q never  
rhel02    libstoragemgmt  /usr/bin/lsmd -d  
rhel02    root            /usr/sbin/gssproxy -D  
rhel02    polkitd         /usr/lib/polkit-1/polkitd --no-debug  
rhel02    root            /usr/lib/systemd/systemd-logind  
rhel02    dbus            /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation  
rhel02    root            /usr/sbin/NetworkManager --no-daemon  
rhel02    root            /usr/bin/rhsmcertd  
rhel02    root            /usr/sbin/sshd -D  
rhel02    root            /usr/bin/python2 -Es /usr/sbin/tuned -l -P  
rhel02    root            /usr/sbin/rsyslogd -n  
rhel02    root            /usr/sbin/atd -f  
rhel02    root            /usr/sbin/crond -n  
rhel02    root            login -- root  
rhel02    root            rhnsd  
rhel02    root            /usr/libexec/postfix/master -w  
rhel02    postfix         qmgr -l -t unix -u  
rhel02    root            [kworker/u2:1]  
rhel02    postfix         pickup -l -t unix -u  
rhel02    root            [kworker/0:0]  
rhel02    root            [kworker/0:2]  
rhel02    root            [kworker/0:1]  
rhel02    root            [kworker/0:3]  
rhel02    root            sshd: helperchoi [priv]  
rhel02    helperchoi          sshd: helperchoi@pts/0  
rhel02    root            /bin/bash /home/helperchoi/ANSIBLE_SCRIPT/SUB_SCRIPT/sub_ci_collect.sh  
rhel01    root            /sbin/init  
rhel01    root            [kthreadd]  
rhel01    root            [migration/0]  
rhel01    root            [ksoftirqd/0]  
rhel01    root            [stopper/0]  
rhel01    root            [watchdog/0]  
rhel01    root            [events/0]  
rhel01    root            [events/0]  
rhel01    root            [events_long/0]  
rhel01    root            [events_power_ef]  
rhel01    root            [cgroup]  
rhel01    root            [khelper]  
rhel01    root            [netns]  
rhel01    root            [async/mgr]  
rhel01    root            [pm]  
rhel01    root            [sync_supers]  
rhel01    root            [bdi-default]  
rhel01    root            [kintegrityd/0]  
rhel01    root            [kblockd/0]  
rhel01    root            [kacpid]  
rhel01    root            [kacpi_notify]  
rhel01    root            [kacpi_hotplug]  
rhel01    root            [ata_aux]  
rhel01    root            [ata_sff/0]  
rhel01    root            [ksuspend_usbd]  
rhel01    root            [khubd]  
rhel01    root            [kseriod]  
rhel01    root            [md/0]  
rhel01    root            [md_misc/0]  
rhel01    root            [linkwatch]  
rhel01    root            [khungtaskd]  
rhel01    root            [lru-add-drain/0]  
rhel01    root            [kswapd0]  
rhel01    root            [ksmd]  
rhel01    root            [aio/0]  
rhel01    root            [crypto/0]  
rhel01    root            [kthrotld/0]  
rhel01    root            [usbhid_resumer]  
rhel01    root            [deferwq]  
rhel01    root            [kdmremove]  
rhel01    root            [kstriped]  
rhel01    root            [ttm_swap]  
rhel01    root            [scsi_eh_0]  
rhel01    root            [scsi_eh_1]  
rhel01    root            [scsi_eh_2]  
rhel01    root            [kdmflush]  
rhel01    root            [kdmflush]  
rhel01    root            [jbd2/dm-0-8]  
rhel01    root            [ext4-dio-unwrit]  
rhel01    root            /sbin/udevd -d  
rhel01    root            /sbin/udevd -d  
rhel01    root            /sbin/udevd -d  
rhel01    root            [jbd2/sda1-8]  
rhel01    root            [ext4-dio-unwrit]  
rhel01    root            [kauditd]  
rhel01    root            [ib_addr]  
rhel01    root            [infiniband/0]  
rhel01    root            [ib_mcast]  
rhel01    root            [iw_cm_wq]  
rhel01    root            [ib_cm/0]  
rhel01    root            [rdma_cm]  
rhel01    root            [ipoib_flush]  
rhel01    root            [flush-253:0]  
rhel01    root            auditd  
rhel01    root            /sbin/rsyslogd -i /var/run/syslogd.pid -c 5  
rhel01    root            /usr/sbin/sshd  
rhel01    root            /usr/libexec/postfix/master  
rhel01    root            crond  
rhel01    postfix         qmgr -l -t fifo -u  
rhel01    root            /usr/bin/rhsmcertd  
rhel01    root            login -- root  
rhel01    root            /sbin/mingetty /dev/tty2  
rhel01    root            /sbin/mingetty /dev/tty3  
rhel01    root            /sbin/mingetty /dev/tty4  
rhel01    root            /sbin/mingetty /dev/tty5  
rhel01    root            /sbin/mingetty /dev/tty6  
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
centos01  tcp   0.0.0.0:*              0.0.0.0:46198          LISTEN       1177/rpc.statd 
centos01  tcp   0.0.0.0:*              127.0.0.1:953          LISTEN       9926/named 
centos01  tcp   0.0.0.0:*              127.0.0.1:25           LISTEN       1495/master 
centos01  tcp   0.0.0.0:*              0.0.0.0:3260           LISTEN       - 
centos01  tcp   0.0.0.0:*              0.0.0.0:2049           LISTEN       - 
centos01  tcp   192.168.137.30:58589   192.168.137.10:749     ESTABLISHED  - 
centos01  tcp   192.168.137.10:22      192.168.137.10:42314   ESTABLISHED  23597/ssh: 
centos01  tcp   192.168.137.30:22      192.168.137.10:55364   ESTABLISHED  23820/ssh: 
centos01  tcp   192.168.137.1:56876    192.168.137.10:22      ESTABLISHED  20472/sshd: 
centos01  tcp   192.168.137.40:22      192.168.137.10:59230   ESTABLISHED  23604/ssh: 
centos01  tcp   192.168.137.50:22      192.168.137.10:41724   ESTABLISHED  23616/ssh: 
centos01  tcp   192.168.137.20:22      192.168.137.10:50762   ESTABLISHED  23601/ssh: 
centos01  tcp   192.168.137.10:42314   192.168.137.10:22      ESTABLISHED  23589/sshd: 
centos01  tcp   192.168.100.110:56000  192.168.100.100:3260   ESTABLISHED  - 
centos01  tcp   192.168.137.1:60823    192.168.137.10:22      ESTABLISHED  21974/sshd: 
centos01  tcp   192.168.137.30:770     192.168.137.10:2049    ESTABLISHED  - 
centos01  tcp6  :::*                   :::111                 LISTEN       858/rpcbind 
centos01  tcp6  :::*                   :::80                  LISTEN       26668/httpd 
centos01  tcp6  :::*                   :::20048               LISTEN       1223/rpc.mountd 
centos01  tcp6  :::*                   ::1:53                 LISTEN       9926/named 
centos01  tcp6  :::*                   :::22                  LISTEN       1612/sshd 
centos01  tcp6  :::*                   ::1:953                LISTEN       9926/named 
centos01  tcp6  :::*                   ::1:25                 LISTEN       1495/master 
centos01  tcp6  :::*                   :::44665               LISTEN       1177/rpc.statd 
centos01  tcp6  :::*                   :::8443                LISTEN       26668/httpd 
centos01  tcp6  :::*                   :::38272               LISTEN       - 
centos01  tcp6  :::*                   :::2049                LISTEN       - 
centos03  tcp   0.0.0.0:*              0.0.0.0:22             LISTEN       836/sshd 
centos03  tcp   0.0.0.0:*              127.0.0.1:25           LISTEN       913/master 
centos03  tcp   0.0.0.0:*              0.0.0.0:58589          LISTEN       - 
centos03  tcp   192.168.137.10:55364   192.168.137.30:22      ESTABLISHED  26866/sshd 
centos03  tcp   192.168.137.10:2049    192.168.137.30:770     ESTABLISHED  - 
centos03  tcp   192.168.137.10:749     192.168.137.30:58589   ESTABLISHED  - 
centos03  tcp   :::*                   :::22                  LISTEN       836/sshd 
centos03  tcp   :::*                   ::1:25                 LISTEN       913/master 
centos03  tcp   :::*                   :::35835               LISTEN       - 
centos02  tcp   0.0.0.0:*              0.0.0.0:111            LISTEN       868/rpcbind 
centos02  tcp   0.0.0.0:*              0.0.0.0:22             LISTEN       1282/sshd 
centos02  tcp   0.0.0.0:*              127.0.0.1:25           LISTEN       1586/master 
centos02  tcp   192.168.137.10:50762   192.168.137.20:22      ESTABLISHED  15815/sshd: 
centos02  tcp   192.168.100.100:3260   192.168.100.110:56000  ESTABLISHED  1291/iscsid 
centos02  tcp6  :::*                   127.0.0.1:8005         LISTEN       1284/java 
centos02  tcp6  :::*                   :::8009                LISTEN       1284/java 
centos02  tcp6  :::*                   :::111                 LISTEN       868/rpcbind 
centos02  tcp6  :::*                   :::8080                LISTEN       1284/java 
centos02  tcp6  :::*                   :::22                  LISTEN       1282/sshd 
centos02  tcp6  :::*                   ::1:25                 LISTEN       1586/master 
rhel02    tcp   0.0.0.0:*              0.0.0.0:22             LISTEN       1051/sshd 
rhel02    tcp   0.0.0.0:*              127.0.0.1:25           LISTEN       1310/master 
rhel02    tcp   0.0.0.0:*              0.0.0.0:111            LISTEN       785/rpcbind 
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

# [ END ]
