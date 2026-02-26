#!/bin/bash
#Script made by helperchoi@mz.co.kr
SCRIPT_VER=0.2.20260226

export LANG=C
export LC_ALL=C

DIREC_LIST=`find / -maxdepth 1 -type d | egrep -iv "^/$|^/cdrom$|^/snap$|^/boot$|^/proc$|^/dev$|^/run$|^/sys$|^/etc$|^/root$|^/var$|^/tmp$|^/usr$|^/media$|^/mnt$|^/srv$|^/opt$|^/lost\+found$|is-merged$"`

for LIST in ${DIREC_LIST}
do
        MOUNT_CHECK=`df -hTP | grep "${LIST}$" | wc -l`
        if [ ${MOUNT_CHECK} -eq 0 ]
        then
                export M_POINT_SIZE=`df -hTP / | grep -vi "filesystem" | awk '{print $3}'`
                export M_POINT="/"
        else
                export M_POINT_SIZE=`df -hTP ${LIST} | grep -vi "filesystem" | awk '{print $3}'`
                export M_POINT="${LIST}"
        fi

        echo "[CHECK_RESULT] ${HOSTNAME} | Mount Point : ${M_POINT} | Mount Size : ${M_POINT_SIZE} | Dir Name : ${LIST}"
done
