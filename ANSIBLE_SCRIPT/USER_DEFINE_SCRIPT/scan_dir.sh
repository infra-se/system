#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.1.20231116

export LANG=C
export LC_ALL=C

DIREC_LIST=`find / -maxdepth 1 -type d | egrep -iv "^/$|^/boot$|^/proc$|^/dev$|^/run$|^/sys$|^/etc$|^/root$|^/var$|^/tmp$|^/usr$|^/media$|^/mnt$|^/srv$|^/opt$|^/lost\+found$"`

for LIST in ${DIREC_LIST}
do
        #FILE_COUNT=`find ${LIST} -type f | wc -l`
	FILE_COUNT=`ls -AlR ${LIST} | egrep -v ':$|^total|^$|^d' | wc -l`
        USED_SIZE=`du -sh ${LIST} | awk '{print $1}'`
        MOUNT_CHECK=`df -hTP | grep "${LIST}$" | wc -l`
        if [ ${MOUNT_CHECK} -eq 0 ]
        then
                export M_POINT_SIZE=`df -hTP / | grep -vi "filesystem" | awk '{print $3}'`
                export M_USED_SIZE=`df -hTP / | grep -vi "filesystem" | awk '{print $4}'`
                export M_POINT="/"
        else
                export M_POINT_SIZE=`df -hTP ${LIST} | grep -vi "filesystem" | awk '{print $3}'`
                export M_USED_SIZE=`df -hTP ${LIST} | grep -vi "filesystem" | awk '{print $4}'`
                export M_POINT="${LIST}"
        fi

        echo "[CHECK_RESULT] ${HOSTNAME}|${M_POINT}|${M_POINT_SIZE}|${M_USED_SIZE}|${LIST}|${USED_SIZE}|${FILE_COUNT}"
done

