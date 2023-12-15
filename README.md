# Github URL : https://github.com/infra-se/system
# Description : Linux System Engineering & Infra automation Code

## [ Usage ]
1. wget -O - https://github.com/infra-se/system/blob/main/get_script.sh?raw=true | bash
```
[root@centos01 ~]# 
[root@centos01 ~]# id
uid=0(root) gid=0(root) groups=0(root)
[root@centos01 ~]# 
[root@centos01 ~]# wget -O - https://github.com/infra-se/system/blob/main/get_script.sh?raw=true | bash
--2023-12-14 23:55:25--  https://github.com/infra-se/system/blob/main/get_script.sh?raw=true

...

100%[===================================================================================================================>] 783         --.-K/s   in 0s      

2023-12-14 23:55:26 (33.8 MB/s) - written to stdout [783/783]


[INFO] Script Path Initialize : /root/shell
Cloning into 'system'...
remote: Enumerating objects: 271, done.
remote: Counting objects: 100% (128/128), done.
remote: Compressing objects: 100% (111/111), done.
remote: Total 271 (delta 84), reused 17 (delta 17), pack-reused 143
Receiving objects: 100% (271/271), 94.03 KiB | 0 bytes/s, done.
Resolving deltas: 100% (137/137), done.

[INFO] Script Download Path : /root/shell
/root/shell/management_os/all_user_fd_cnt.sh
/root/shell/management_os/change_oom_score.sh
/root/shell/management_os/check_ethernet_info.sh
/root/shell/management_os/check_java_instance.sh
/root/shell/management_os/check_os.sh
/root/shell/management_os/check_web.sh
/root/shell/management_os/use_swap.sh
/root/shell/management_os/user_define_fd_cnt.sh
/root/shell/management_os/user_define_session_cnt.sh
/root/shell/management_git/0_git_push_dont_pr.sh
/root/shell/management_git/1_pr_branch.sh
/root/shell/management_git/2_delete_branch.sh

[root@centos01 ~]# 
```
